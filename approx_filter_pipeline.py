"""
approx_filter_pipeline.py
=========================
Gaussian smoothing + Sobel edge detection via Vivado xsim.

BUG FIXED: Each design now compiles into its OWN isolated xsim work library
using  xvlog --work <lib_name> ...  and  xelab <lib_name>.tb_<design>
This prevents sub-module collisions (Full_Adder, Half_Adder, etc.) between
designs that share the same helper modules.

USAGE
-----
    python approx_filter_pipeline.py

SETUP
-----
1. Source Vivado:
       Linux:   source /path/to/Vivado/2023.x/settings64.sh
       Windows: run settings64.bat  or open Vivado Tcl Console cmd
2. pip install numpy pillow scikit-image tifffile matplotlib
3. Edit CONFIG block below.

MODULE PORT REQUIREMENT
-----------------------
Each top-level .v module must have exactly:
    input  [7:0]  A
    input  [7:0]  B
    output [15:0] P
"""

import os
import sys
import subprocess
import numpy as np
from PIL import Image
import tifffile
from skimage.metrics import structural_similarity as ssim_fn
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import csv


# ===========================================================================
# CONFIG — UPDATED FOR YOUR SYSTEM
# ===========================================================================

VERILOG_DIR = r"C:\Users\ankit\8x8 Multiplier\8x8 Multiplier.srcs\sources_1\new"

INPUT_IMAGE  = r"C:\Users\ankit\8x8 Multiplier\images\input.jpg"

RESULTS_DIR  = r"C:\Users\ankit\8x8 Multiplier\results"

SIM_WORK_DIR = r"C:\Users\ankit\8x8 Multiplier\sim_work"

# Vivado binaries
XVLOG_BIN = r"C:/Xilinx/Vivado/2024.2/bin/xvlog.bat"
XELAB_BIN = r"C:/Xilinx/Vivado/2024.2/bin/xelab.bat"
XSIM_BIN  = r"C:/Xilinx/Vivado/2024.2/bin/xsim.bat"


# ===========================================================================
# YOUR DESIGNS
# ===========================================================================

DESIGNS = {
    "PBO_3_8X8"             : "PBO-3  8x8   (recursive, low approximation)",
    "PBO_5_8X8"             : "PBO-5  8x8   (recursive)",
    "PBO_7_8X8"             : "PBO-7  8x8   (recursive, high approximation)",
    "PBOM8_53N"             : "PBOM8_53N    (cols 2-6 M2, cols 2-4 M1, exact adder)",
    "PBOM8_73Y"             : "PBOM8_73Y    (cols 2-8 M2, cols 2-4 M1, approx adder)",
    "PBOM8_8bits"           : "PBOM8_8bits  (bit-wise, 8 approx cols)",
    "PBOM8_11bits"          : "PBOM8_11bits (bit-wise, 11 approx cols)",
    "Hybrid_Multiplier_8x8" : "Hybrid 8x8   (compressor-based)",
}

# ===========================================================================
# SHARED DEPENDENCIES
# ===========================================================================

SHARED_DEPS = [
    "Full_Adder.v",
    "Half_Adder.v",
    "compressor_1.v",
    "compressor_2.v",
    "Multiplier_4x4.v",
    "multiplier_8x4.v",
    "mul_1_8x4.v",
    "mul_2_8x4.v",
    "PBO_3.v",
    "PBO_5.v",
    "PBO_7.v",
]

# ===========================================================================
# FILTERS
# ===========================================================================

GAUSSIAN_KERNEL = np.array([
    [ 95, 118,  95],
    [118, 148, 118],
    [ 95, 118,  95],
], dtype=np.int32)

GAUSSIAN_SCALE = 1000

SOBEL_KX = np.array([
    [-1, 0, 1],
    [-2, 0, 2],
    [-1, 0, 1]
], dtype=np.int32)

SOBEL_KY = SOBEL_KX.T.copy()


# ===========================================================================
# TESTBENCH TEMPLATE
# ===========================================================================

TB_TEMPLATE = """\
`timescale 1ns/1ps
module tb_{design};

    reg  [7:0]  A, B;
    wire [15:0] P;

    {design} dut (
        .A(A),
        .B(B),
        .P(P)
    );

    integer fin, fout, code;
    reg [7:0] a_val, b_val;

    initial begin
        fin  = $fopen("{input_file}", "r");
        fout = $fopen("{output_file}", "w");

        if (fin  == 0) begin
            $display("ERROR: cannot open input file");
            $finish;
        end

        if (fout == 0) begin
            $display("ERROR: cannot open output file");
            $finish;
        end

        while (!$feof(fin)) begin
            code = $fscanf(fin, "%h %h\\n", a_val, b_val);

            if (code == 2) begin
                A = a_val;
                B = b_val;

                #10;

                $fdisplay(fout, "%h", P);
            end
        end

        $fclose(fin);
        $fclose(fout);

        $finish;
    end

endmodule
"""


# ===========================================================================
# MULTIPLIER RUNNER
# ===========================================================================

class MultiplierRunner:

    def __init__(self, design_name):

        self.design = design_name

        self.work_dir = os.path.abspath(
            os.path.join(SIM_WORK_DIR, design_name)
        )

        self.vlog_src = os.path.join(
            VERILOG_DIR,
            f"{design_name}.v"
        )

        # PRIVATE LIBRARY NAME
        self.lib_name = f"lib_{design_name}"

        self._compiled = False

        os.makedirs(self.work_dir, exist_ok=True)

    # ----------------------------------------------------------------------

    def compile(self):

        if self._compiled:
            return

        self._inp_file = os.path.join(self.work_dir, "inputs.hex")
        self._out_file = os.path.join(self.work_dir, "outputs.hex")

        # WRITE TESTBENCH
        tb_code = TB_TEMPLATE.format(
            design      = self.design,
            input_file  = self._inp_file.replace("\\", "/"),
            output_file = self._out_file.replace("\\", "/"),
        )

        tb_path = os.path.join(
            self.work_dir,
            f"tb_{self.design}.v"
        )

        with open(tb_path, "w") as f:
            f.write(tb_code)

        # --------------------------------------------------------------
        # COMPILE SHARED DEPENDENCIES
        # --------------------------------------------------------------

        for dep in SHARED_DEPS:

            dep_path = os.path.join(VERILOG_DIR, dep)

            if os.path.isfile(dep_path):

                self._run(
                    [
                        XVLOG_BIN,
                        "--work",
                        self.lib_name,
                        "--log",
                        f"xvlog_{dep}.log",
                        dep_path
                    ],
                    f"xvlog_{dep}"
                )

        # --------------------------------------------------------------
        # COMPILE DUT
        # --------------------------------------------------------------

        self._run(
            [
                XVLOG_BIN,
                "--work",
                self.lib_name,
                "--log",
                "xvlog_dut.log",
                self.vlog_src
            ],
            "xvlog_dut"
        )

        # --------------------------------------------------------------
        # COMPILE TESTBENCH
        # --------------------------------------------------------------

        self._run(
            [
                XVLOG_BIN,
                "--work",
                self.lib_name,
                "--log",
                "xvlog_tb.log",
                tb_path
            ],
            "xvlog_tb"
        )

        # --------------------------------------------------------------
        # XELAB
        # --------------------------------------------------------------

        snap = f"snap_{self.design}"

        # Build the lib path and wrap it in quotes so spaces in the
        # directory name (e.g. "8x8 Multiplier") are not split by
        # the Windows command-line parser inside xelab.
        lib_path = os.path.join(self.work_dir, self.lib_name)
        lib_arg  = f'{self.lib_name}={lib_path}'

        self._run(
            [
                XELAB_BIN,
                f"{self.lib_name}.tb_{self.design}",
                "--lib", lib_arg,
                "--snapshot", snap,
                "--log", "xelab.log",
            ],
            "xelab"
        )

        self._snap = snap

        self._compiled = True

    # ----------------------------------------------------------------------

    def multiply_batch(self, a_vals, b_vals):

        self.compile()

        a_vals = np.asarray(a_vals, dtype=np.uint8)
        b_vals = np.asarray(b_vals, dtype=np.uint8)

        assert a_vals.shape == b_vals.shape

        with open(self._inp_file, "w") as f:

            for a, b in zip(a_vals.flat, b_vals.flat):
                f.write(f"{int(a):02x} {int(b):02x}\n")

        if os.path.exists(self._out_file):
            os.remove(self._out_file)

        # RUN XSIM
        self._run(
            [
                XSIM_BIN,
                self._snap,
                "--runall",
                "--log",
                "xsim.log"
            ],
            "xsim_run"
        )

        if not os.path.exists(self._out_file):

            raise RuntimeError(
                f"xsim produced no output for {self.design}"
            )

        results = []

        with open(self._out_file) as f:

            for line in f:

                s = line.strip()

                if s:
                    results.append(int(s, 16))

        return np.array(results, dtype=np.uint32)

    # ----------------------------------------------------------------------

    def _run(self, cmd, tag):

        log = os.path.join(self.work_dir, f"{tag}.log")

        # On Windows, .bat files must be invoked via the shell so that
        # cmd.exe handles them correctly. subprocess with a list +
        # shell=True on Windows passes the list through
        # subprocess.list2cmdline, which double-quotes any argument
        # containing spaces — fixing paths like "8x8 Multiplier\...".
        is_windows = sys.platform.startswith("win")

        r = subprocess.run(
            cmd,
            cwd=self.work_dir,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            shell=is_windows,
        )

        with open(log, "w") as f:
            f.write(r.stdout)

        if r.returncode != 0:

            print(f"\n[ERROR] {tag} failed for {self.design}")

            print("\n".join(
                r.stdout.strip().splitlines()[-30:]
            ))

            print(f"\nFull log: {log}")

            raise RuntimeError(f"{tag} failed")

        print(f"    [{self.design}] {tag}: OK")


# ===========================================================================
# HELPER
# ===========================================================================

def _batch_products(runner, A_list, B_list, H, W):

    raw = runner.multiply_batch(
        np.concatenate(A_list).astype(np.uint8),
        np.concatenate(B_list).astype(np.uint8)
    ).astype(np.int64)

    return [
        raw[k * H * W : (k + 1) * H * W]
        for k in range(len(A_list))
    ]


# ===========================================================================
# GAUSSIAN
# ===========================================================================

def apply_gaussian(img, runner):

    H, W = img.shape

    padded = np.pad(img.astype(np.int32), 1, mode='reflect')

    kf = GAUSSIAN_KERNEL.flatten()

    A_list = [
        padded[ki:ki+H, kj:kj+W].flatten()
        for ki in range(3)
        for kj in range(3)
    ]

    B_list = [
        np.full(H * W, int(kf[k]), dtype=np.uint8)
        for k in range(9)
    ]

    patches = _batch_products(
        runner,
        A_list,
        B_list,
        H,
        W
    )

    accum = sum(patches)

    return np.clip(
        (accum // GAUSSIAN_SCALE).reshape(H, W),
        0,
        255
    ).astype(np.uint8)


# ===========================================================================
# SOBEL
# ===========================================================================

def apply_sobel(img, runner):

    H, W = img.shape

    padded = np.pad(img.astype(np.int32), 1, mode='reflect')

    kxf = SOBEL_KX.flatten()
    kyf = SOBEL_KY.flatten()

    A_list = [
        padded[ki:ki+H, kj:kj+W].flatten()
        for ki in range(3)
        for kj in range(3)
    ]

    Bx_list = [
        np.full(H * W, abs(int(kxf[k])), dtype=np.uint8)
        for k in range(9)
    ]

    By_list = [
        np.full(H * W, abs(int(kyf[k])), dtype=np.uint8)
        for k in range(9)
    ]

    px = _batch_products(runner, A_list, Bx_list, H, W)
    py = _batch_products(runner, A_list, By_list, H, W)

    sign_x = [int(np.sign(v)) for v in kxf]
    sign_y = [int(np.sign(v)) for v in kyf]

    gx = sum(sign_x[k] * px[k] for k in range(9))
    gy = sum(sign_y[k] * py[k] for k in range(9))

    mag = np.sqrt(
        gx.astype(np.float64)**2 +
        gy.astype(np.float64)**2
    )

    return np.clip(
        mag,
        0,
        255
    ).astype(np.uint8).reshape(H, W)


# ===========================================================================
# EXACT REFERENCES
# ===========================================================================

def exact_gaussian(img):

    H, W = img.shape

    padded = np.pad(img.astype(np.int64), 1, mode='reflect')

    out = sum(
        int(GAUSSIAN_KERNEL[ki, kj]) *
        padded[ki:ki+H, kj:kj+W]
        for ki in range(3)
        for kj in range(3)
    )

    return np.clip(
        out // GAUSSIAN_SCALE,
        0,
        255
    ).astype(np.uint8)


def exact_sobel(img):

    H, W = img.shape

    padded = np.pad(img.astype(np.int64), 1, mode='reflect')

    gx = sum(
        int(SOBEL_KX[ki, kj]) *
        padded[ki:ki+H, kj:kj+W]
        for ki in range(3)
        for kj in range(3)
    )

    gy = sum(
        int(SOBEL_KY[ki, kj]) *
        padded[ki:ki+H, kj:kj+W]
        for ki in range(3)
        for kj in range(3)
    )

    return np.clip(
        np.sqrt(
            gx.astype(np.float64)**2 +
            gy.astype(np.float64)**2
        ),
        0,
        255
    ).astype(np.uint8)


# ===========================================================================
# METRICS
# ===========================================================================

def compute_metrics(ref, approx):

    mse = np.mean(
        (
            ref.astype(np.float64) -
            approx.astype(np.float64)
        ) ** 2
    )

    psnr = (
        float('inf')
        if mse == 0
        else 10 * np.log10(255.0**2 / mse)
    )

    ssim = ssim_fn(ref, approx, data_range=255)

    return psnr, ssim


# ===========================================================================
# IMAGE I/O
# ===========================================================================

def load_gray(path):

    if path.lower().endswith(('.tif', '.tiff')):
        img = tifffile.imread(path)

    else:
        img = np.array(Image.open(path))

    if img.ndim == 3:

        img = (
            0.2989 * img[..., 0] +
            0.5870 * img[..., 1] +
            0.1140 * img[..., 2]
        ).astype(np.uint8)

    elif img.dtype != np.uint8:

        img = (
            (img.astype(np.float64) / img.max()) * 255
        ).astype(np.uint8)

    return img


def save_img(arr, path):

    Image.fromarray(arr).save(path)


# ===========================================================================
# MENUS
# ===========================================================================

def pick_image():

    print(f"\n  Default image: {INPUT_IMAGE}")

    p = input(
        "  Press Enter to use default, or type path: "
    ).strip()

    return p or INPUT_IMAGE


def pick_designs():

    keys = list(DESIGNS.keys())

    print("\n" + "="*65)
    print("  Select designs to run")
    print("="*65)

    for i, k in enumerate(keys):
        print(f"  [{i+1:2d}]  {k:<28}  {DESIGNS[k]}")

    print(f"  [ A]  All designs")
    print("="*65)

    raw = input(
        "\n  Enter numbers (e.g. 1 3 5) or A for all: "
    ).strip()

    if raw.upper() == "A":
        return keys

    chosen = []

    for tok in raw.split():
        try:
            idx = int(tok) - 1
            if 0 <= idx < len(keys):
                chosen.append(keys[idx])
        except Exception:
            pass

    if not chosen:
        print("Nothing selected.")
        sys.exit(0)

    return chosen


def pick_filter():

    print("\n  Which filter?")
    print("  [1] Gaussian smoothing")
    print("  [2] Sobel edge detection")
    print("  [3] Both")

    c = input("  Choice: ").strip()

    return {
        "1": "gaussian",
        "2": "sobel",
        "3": "both"
    }.get(c, "both")


# ===========================================================================
# TABLE
# ===========================================================================

def print_table(rows, title):

    print(f"\n{'='*68}")
    print(f"  {title}")
    print(f"{'='*68}")
    print(f"  {'Design':<28}  {'PSNR (dB)':>14}  {'SSIM':>8}")
    print(f"  {'-'*28}  {'-'*14}  {'-'*8}")

    for name, p, s in rows:

        ps = (
            "∞ (exact)"
            if p == float('inf')
            else f"{p:.4f}"
        )

        print(f"  {name:<28}  {ps:>14}  {s:.6f}")

    print(f"{'='*68}")


# ===========================================================================
# MAIN  — BUG FIX: filter blocks are now properly inside the design loop
# ===========================================================================

def main():

    print("\n" + "="*65)
    print(" Approximate Multiplier Image Filter Pipeline ")
    print("="*65)

    image_path = pick_image()
    chosen     = pick_designs()
    filt       = pick_filter()

    if not os.path.isfile(image_path):
        print(f"\nERROR: image not found: {image_path}")
        sys.exit(1)

    missing = [
        d for d in chosen
        if not os.path.isfile(os.path.join(VERILOG_DIR, f"{d}.v"))
    ]

    if missing:
        print("\nERROR: missing .v files")
        for m in missing:
            print(os.path.join(VERILOG_DIR, m + ".v"))
        sys.exit(1)

    print(f"\n[Loading image] {image_path}")
    img = load_gray(image_path)
    print(f"Shape: {img.shape}")

    # ------------------------------------------------------------------
    # Create output directories
    # ------------------------------------------------------------------
    gauss_dir = os.path.join(RESULTS_DIR, "gaussian")
    sobel_dir = os.path.join(RESULTS_DIR, "sobel")
    os.makedirs(gauss_dir, exist_ok=True)
    os.makedirs(sobel_dir, exist_ok=True)

    # ------------------------------------------------------------------
    # Exact reference images
    # ------------------------------------------------------------------
    print("\n[Computing exact references...]")

    ref_g = exact_gaussian(img)
    ref_s = exact_sobel(img)

    save_img(ref_g, os.path.join(gauss_dir, "exact_reference.png"))
    print(f"  Saved: {os.path.join(gauss_dir, 'exact_reference.png')}")

    save_img(ref_s, os.path.join(sobel_dir, "exact_reference.png"))
    print(f"  Saved: {os.path.join(sobel_dir, 'exact_reference.png')}")

    gauss_rows = []
    sobel_rows = []

    # ------------------------------------------------------------------
    # Per-design loop  ← filter blocks MUST stay inside this loop
    # ------------------------------------------------------------------
    for design in chosen:

        print(f"\n{'─'*60}")
        print(f"  Design: {design}")
        print(f"{'─'*60}")

        runner = MultiplierRunner(design)

        # --------------------------------------------------------------
        # GAUSSIAN
        # --------------------------------------------------------------
        if filt in ("gaussian", "both"):

            print("  Running Gaussian filter...")

            out_g = apply_gaussian(img, runner)

            out_path = os.path.join(gauss_dir, f"{design}.png")
            save_img(out_g, out_path)
            print(f"  Saved: {out_path}")

            p, s = compute_metrics(ref_g, out_g)
            gauss_rows.append((design, p, s))
            print(f"  PSNR = {p:.4f} dB   SSIM = {s:.6f}")

        # --------------------------------------------------------------
        # SOBEL
        # --------------------------------------------------------------
        if filt in ("sobel", "both"):

            print("  Running Sobel filter...")

            out_s = apply_sobel(img, runner)

            out_path = os.path.join(sobel_dir, f"{design}.png")
            save_img(out_s, out_path)
            print(f"  Saved: {out_path}")

            p, s = compute_metrics(ref_s, out_s)
            sobel_rows.append((design, p, s))
            print(f"  PSNR = {p:.4f} dB   SSIM = {s:.6f}")

    # ------------------------------------------------------------------
    # Summary tables
    # ------------------------------------------------------------------
    if gauss_rows:
        print_table(gauss_rows, "Gaussian Results")

    if sobel_rows:
        print_table(sobel_rows, "Sobel Results")

    print("\n[Done]  All output images saved to:", RESULTS_DIR)


# ===========================================================================
# EXECUTE
# ===========================================================================

if __name__ == "__main__":
    main()