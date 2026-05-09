"""
approx_filter_pipeline.py
=========================
Gaussian smoothing + Sobel edge detection using your Verilog approximate
multipliers in Vivado xsim.

USAGE
-----
Just run:
    python approx_filter_pipeline.py

You will be shown a menu to pick which designs to run and which filter.

SETUP
-----
1. Source Vivado first:
       Linux:   source /path/to/Vivado/2023.x/settings64.sh
       Windows: run settings64.bat or open Vivado Tcl Console

2. pip install numpy pillow scikit-image tifffile matplotlib

3. Edit the CONFIG block below:
   - VERILOG_DIR  → your sources_1/new folder path
   - INPUT_IMAGE  → your .tif image path

YOUR MODULE PORT REQUIREMENT
-----------------------------
Each .v module must have EXACTLY these port names:
    input  [7:0]  A
    input  [7:0]  B
    output [15:0] P
If different, edit TB_TEMPLATE below.
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


# CONFIG — EDIT THESE


VERILOG_DIR = r"C:\Users\ankit\8x8 Multiplier\8x8 Multiplier.srcs\sources_1\new"

INPUT_IMAGE  = r"C:\Users\ankit\8x8 Multiplier\images\moon-blurred.tif"
RESULTS_DIR  = r"C:\Users\ankit\8x8 Multiplier\results"
SIM_WORK_DIR = "./sim_work"

# Vivado binaries (leave as-is if Vivado is sourced/on PATH)
XVLOG_BIN = r"C:/Xilinx/Vivado/2024.2/bin/xvlog.bat"
XELAB_BIN = r"C:/Xilinx/Vivado/2024.2/bin/xelab.bat"
XSIM_BIN  = r"C:/Xilinx/Vivado/2024.2/bin/xsim.bat"


# ===========================================================================
# YOUR DESIGNS  (exact filename without .v  →  description for menu)
# ===========================================================================
DESIGNS = {
    "PBO_3_8X8"             : "PBO-3  8x8   (recursive, low approx)",
    "PBO_5_8X8"             : "PBO-5  8x8   (recursive)",
    "PBO_7_8X8"             : "PBO-7  8x8   (recursive, high approx)",
    "PBOM8_53N"             : "PBOM8_53N    (cols 2-6 M2, cols 2-4 M1, exact adder)",
    "PBOM8_73Y"             : "PBOM8_73Y    (cols 2-8 M2, cols 2-4 M1, approx adder)",
    "PBOM8_8bits"           : "PBOM8_8bits  (bit-wise, 8 approx cols)",
    "PBOM8_11bits"          : "PBOM8_11bits (bit-wise, 11 approx cols)",
    "Hybrid_Multiplier_8x8" : "Hybrid 8x8   (compressor-based)",
}



# Filters — exactly as per paper Section VII-A


# Eq.(8) modified Gaussian 3x3 integer kernel, divide output by 1000
GAUSSIAN_KERNEL = np.array([
    [ 95, 118,  95],
    [118, 148, 118],
    [ 95, 118,  95],
], dtype=np.int32)
GAUSSIAN_SCALE = 1000

# Eq.(9) Sobel 3x3
SOBEL_KX = np.array([[-1,0,1],[-2,0,2],[-1,0,1]], dtype=np.int32)
SOBEL_KY = SOBEL_KX.T.copy()



# Testbench template (auto-generated — do NOT create this in Vivado)

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
        if (fin  == 0) begin $display("ERROR: cannot open input  file"); $finish; end
        if (fout == 0) begin $display("ERROR: cannot open output file"); $finish; end

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
# MultiplierRunner
# ===========================================================================
class MultiplierRunner:
    def __init__(self, design_name):
        self.design   = design_name
        self.vlog_src = os.path.join(VERILOG_DIR, f"{design_name}.v")
        self.work_dir = os.path.join(SIM_WORK_DIR, design_name)
        os.makedirs(self.work_dir, exist_ok=True)
        self._compiled = False

    def compile(self):
        if self._compiled:
            return
        inp_f = os.path.abspath(os.path.join(self.work_dir, "inputs.hex"))
        out_f = os.path.abspath(os.path.join(self.work_dir, "outputs.hex"))

        tb_code = TB_TEMPLATE.format(
            design      = self.design,
            input_file  = inp_f.replace("\\", "/"),
            output_file = out_f.replace("\\", "/"),
        )
        tb_name = f"tb_{self.design}.v"
        tb_path = os.path.join(self.work_dir, tb_name)
        with open(tb_path, "w") as f:
            f.write(tb_code)

        self._run([XVLOG_BIN, self.vlog_src], "xvlog_dut")
        self._run([XVLOG_BIN, tb_name],       "xvlog_tb")
        self._run([XELAB_BIN, f"tb_{self.design}",
                   "-s", f"tb_{self.design}_sim"], "xelab")

        self._compiled = True
        self._inp_file = inp_f
        self._out_file = out_f

    def multiply_batch(self, a_vals, b_vals):
        self.compile()
        a_vals = np.asarray(a_vals, dtype=np.uint8)
        b_vals = np.asarray(b_vals, dtype=np.uint8)

        with open(self._inp_file, "w") as f:
            for a, b in zip(a_vals.flat, b_vals.flat):
                f.write(f"{int(a):02x} {int(b):02x}\n")

        if os.path.exists(self._out_file):
            os.remove(self._out_file)

        self._run([XSIM_BIN, f"tb_{self.design}_sim",
                   "--runall", "--nolog"], "xsim_run")

        results = []
        with open(self._out_file) as f:
            for line in f:
                s = line.strip()
                if s:
                    results.append(int(s, 16))
        return np.array(results, dtype=np.uint32)

    def _run(self, cmd, tag):
        log = os.path.join(self.work_dir, f"{tag}.log")
        r = subprocess.run(cmd, cwd=self.work_dir,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                           text=True)
        with open(log, "w") as f:
            f.write(r.stdout)
        if r.returncode != 0:
            print(f"\n  [ERROR] {tag} failed. Last 30 log lines:")
            print("\n".join(r.stdout.strip().splitlines()[-30:]))
            print(f"  Full log: {log}\n")
            raise RuntimeError(f"{tag} failed for {self.design}")
        print(f"    [{self.design}] {tag}: OK")


# ===========================================================================
# Filters
# ===========================================================================

def _batch_multiply(runner, A_list, B_list, n_patches, H, W):
    """Stack all patch×kernel pairs into one xsim call."""
    prods = runner.multiply_batch(
        np.concatenate(A_list).astype(np.uint8),
        np.concatenate(B_list).astype(np.uint8)
    ).astype(np.int64)
    return [prods[k*H*W:(k+1)*H*W] for k in range(n_patches)]


def apply_gaussian(img, runner):
    H, W   = img.shape
    padded = np.pad(img.astype(np.int32), 1, mode='reflect')
    kf     = GAUSSIAN_KERNEL.flatten()
    A_list = [padded[ki:ki+H, kj:kj+W].flatten()
              for ki in range(3) for kj in range(3)]
    B_list = [np.full(H*W, kf[k], dtype=np.uint8) for k in range(9)]
    patches = _batch_multiply(runner, A_list, B_list, 9, H, W)
    accum   = sum(patches)
    return np.clip((accum // GAUSSIAN_SCALE).reshape(H, W), 0, 255).astype(np.uint8)


def apply_sobel(img, runner):
    H, W   = img.shape
    padded = np.pad(img.astype(np.int32), 1, mode='reflect')
    kxf, kyf = SOBEL_KX.flatten(), SOBEL_KY.flatten()

    A_list = [padded[ki:ki+H, kj:kj+W].flatten()
              for ki in range(3) for kj in range(3)]
    Bx = [np.full(H*W, abs(int(kxf[k])), dtype=np.uint8) for k in range(9)]
    By = [np.full(H*W, abs(int(kyf[k])), dtype=np.uint8) for k in range(9)]

    px = _batch_multiply(runner, A_list, Bx, 9, H, W)
    py = _batch_multiply(runner, A_list, By, 9, H, W)

    sx = [int(np.sign(v)) for v in kxf]
    sy = [int(np.sign(v)) for v in kyf]
    gx = sum(sx[k]*px[k] for k in range(9))
    gy = sum(sy[k]*py[k] for k in range(9))

    mag = np.sqrt(gx.astype(np.float64)**2 + gy.astype(np.float64)**2)
    return np.clip(mag, 0, 255).astype(np.uint8).reshape(H, W)


# ===========================================================================
# Exact references (pure Python)
# ===========================================================================

def exact_gaussian(img):
    H, W   = img.shape
    padded = np.pad(img.astype(np.int64), 1, mode='reflect')
    out    = sum(GAUSSIAN_KERNEL[ki,kj] * padded[ki:ki+H, kj:kj+W]
                 for ki in range(3) for kj in range(3))
    return np.clip(out // GAUSSIAN_SCALE, 0, 255).astype(np.uint8)


def exact_sobel(img):
    H, W   = img.shape
    padded = np.pad(img.astype(np.int64), 1, mode='reflect')
    gx     = sum(SOBEL_KX[ki,kj]*padded[ki:ki+H,kj:kj+W]
                 for ki in range(3) for kj in range(3))
    gy     = sum(SOBEL_KY[ki,kj]*padded[ki:ki+H,kj:kj+W]
                 for ki in range(3) for kj in range(3))
    return np.clip(np.sqrt(gx**2+gy**2), 0, 255).astype(np.uint8)


# ===========================================================================
# Metrics
# ===========================================================================

def metrics(ref, approx):
    mse  = np.mean((ref.astype(np.float64)-approx.astype(np.float64))**2)
    psnr = float('inf') if mse == 0 else 10*np.log10(255.0**2/mse)
    ssim = ssim_fn(ref, approx, data_range=255)
    return psnr, ssim


# ===========================================================================
# Interactive menus
# ===========================================================================

def pick_image():
    print(f"\n  Default image: {INPUT_IMAGE}")
    p = input("  Press Enter to use it, or type a new path: ").strip()
    return p or INPUT_IMAGE


def pick_designs():
    keys = list(DESIGNS.keys())
    print("\n" + "="*62)
    print("  Select designs to run")
    print("="*62)
    for i, k in enumerate(keys):
        print(f"  [{i+1}]  {k:<28} {DESIGNS[k]}")
    print(f"  [A]  All designs")
    print("="*62)
    raw = input("\n  Enter numbers separated by spaces, or A for all: ").strip()

    if raw.upper() == "A":
        return keys

    chosen = []
    for tok in raw.split():
        try:
            idx = int(tok) - 1
            if 0 <= idx < len(keys):
                chosen.append(keys[idx])
            else:
                print(f"  Skipping out-of-range: {tok}")
        except ValueError:
            print(f"  Skipping invalid: {tok}")

    if not chosen:
        print("  Nothing selected. Exiting.")
        sys.exit(0)
    return chosen


def pick_filter():
    print("\n  Which filter?")
    print("  [1]  Gaussian smoothing")
    print("  [2]  Sobel edge detection")
    print("  [3]  Both")
    c = input("  Enter 1, 2 or 3: ").strip()
    return {"1":"gaussian","2":"sobel","3":"both"}.get(c, "both")


# ===========================================================================
# Results table + grid
# ===========================================================================

def print_table(rows, title):
    print(f"\n{'='*65}")
    print(f"  {title}")
    print(f"{'='*65}")
    print(f"  {'Design':<28}  {'PSNR (dB)':>12}  {'SSIM':>8}")
    print(f"  {'-'*28}  {'-'*12}  {'-'*8}")
    for name, p, s in rows:
        ps = "∞  (exact)" if p == float('inf') else f"{p:.4f}"
        print(f"  {name:<28}  {ps:>12}  {s:.6f}")
    print(f"{'='*65}")


def save_grid(gauss_imgs, sobel_imgs, ref_g, ref_s, gauss_rows, sobel_rows, filt):
    gd = {n:(p,s) for n,p,s in gauss_rows}
    sd = {n:(p,s) for n,p,s in sobel_rows}
    all_names = list(dict.fromkeys(
        [r[0] for r in gauss_rows] + [r[0] for r in sobel_rows]))

    cols       = 2 if filt == "both" else 1
    n_rows     = len(all_names) + 1
    fig, axes  = plt.subplots(n_rows, cols,
                              figsize=(5*cols, 3.5*n_rows), squeeze=False)
    fig.patch.set_facecolor('#111')

    def show(ax, im, title, sub=""):
        ax.imshow(im, cmap='gray', vmin=0, vmax=255)
        ax.set_title(title, color='#eee', fontsize=8, pad=3)
        if sub:
            ax.text(0.5,-0.05, sub, transform=ax.transAxes,
                    ha='center', color='#999', fontsize=7)
        ax.axis('off')

    # Reference row
    if filt in ("gaussian","both"):
        show(axes[0][0], ref_g, "Gaussian — exact")
    if filt in ("sobel","both"):
        ci = 1 if filt=="both" else 0
        show(axes[0][ci], ref_s, "Sobel — exact")

    for i, name in enumerate(all_names):
        r = i + 1
        if filt in ("gaussian","both") and name in gauss_imgs:
            p,s = gd[name]
            ps  = "∞" if p==float('inf') else f"{p:.2f}dB"
            show(axes[r][0], gauss_imgs[name], name, f"PSNR={ps}  SSIM={s:.4f}")
        if filt in ("sobel","both") and name in sobel_imgs:
            p,s = sd[name]
            ps  = "∞" if p==float('inf') else f"{p:.2f}dB"
            ci  = 1 if filt=="both" else 0
            show(axes[r][ci], sobel_imgs[name], name, f"PSNR={ps}  SSIM={s:.4f}")

    for r in range(n_rows):
        for c in range(cols):
            if not axes[r][c].images:
                axes[r][c].set_visible(False)

    plt.tight_layout(pad=1.2)
    out = os.path.join(RESULTS_DIR, "comparison_grid.png")
    plt.savefig(out, dpi=110, facecolor='#111')
    plt.close()
    print(f"[Grid saved → {out}]")


# ===========================================================================
# Main
# ===========================================================================

def main():
    print("\n" + "="*62)
    print("  Approximate Multiplier Image Filter Pipeline")
    print("  Kumari & Paily Palathinkal, IEEE TCAS-I 2025")
    print("="*62)

    image_path = pick_image()
    chosen     = pick_designs()
    filt       = pick_filter()

    if not os.path.isfile(image_path):
        print(f"\nERROR: image not found: {image_path}")
        sys.exit(1)

    missing = [d for d in chosen
               if not os.path.isfile(os.path.join(VERILOG_DIR, f"{d}.v"))]
    if missing:
        print("\nERROR: .v files not found:")
        for m in missing:
            print(f"  {os.path.join(VERILOG_DIR, m+'.v')}")
        print(f"\nCheck VERILOG_DIR in CONFIG:\n  {VERILOG_DIR}")
        sys.exit(1)

    print(f"\n[Loading image] {image_path}")
    img = _load_gray(image_path)
    print(f"  {img.shape}  {img.dtype}")

    os.makedirs(os.path.join(RESULTS_DIR,"gaussian"), exist_ok=True)
    os.makedirs(os.path.join(RESULTS_DIR,"sobel"),    exist_ok=True)

    print("\n[Exact references...]")
    ref_g = exact_gaussian(img)
    ref_s = exact_sobel(img)
    _save(ref_g, os.path.join(RESULTS_DIR,"gaussian","exact_reference.png"))
    _save(ref_s, os.path.join(RESULTS_DIR,"sobel",   "exact_reference.png"))

    gauss_rows, sobel_rows = [], []
    gauss_imgs, sobel_imgs = {}, {}

    for design in chosen:
        print(f"\n{'─'*55}")
        print(f"  {design}  —  {DESIGNS[design]}")
        print(f"{'─'*55}")
        runner = MultiplierRunner(design)

        if filt in ("gaussian","both"):
            print("  Gaussian ...")
            out  = apply_gaussian(img, runner)
            p, s = metrics(ref_g, out)
            _save(out, os.path.join(RESULTS_DIR,"gaussian",f"{design}.png"))
            gauss_rows.append((design,p,s));  gauss_imgs[design] = out
            ps = "∞" if p==float('inf') else f"{p:.4f} dB"
            print(f"    PSNR={ps}   SSIM={s:.6f}")

        if filt in ("sobel","both"):
            print("  Sobel ...")
            out  = apply_sobel(img, runner)
            p, s = metrics(ref_s, out)
            _save(out, os.path.join(RESULTS_DIR,"sobel",f"{design}.png"))
            sobel_rows.append((design,p,s));  sobel_imgs[design] = out
            ps = "∞" if p==float('inf') else f"{p:.4f} dB"
            print(f"    PSNR={ps}   SSIM={s:.6f}")

    if gauss_rows: print_table(gauss_rows, "Gaussian Smoothing Results")
    if sobel_rows: print_table(sobel_rows, "Sobel Edge Detection Results")

    save_grid(gauss_imgs, sobel_imgs, ref_g, ref_s,
              gauss_rows, sobel_rows, filt)

    csv_p = os.path.join(RESULTS_DIR, "metrics.csv")
    with open(csv_p,"w",newline="") as f:
        w = csv.writer(f)
        w.writerow(["Design","Gaussian_PSNR_dB","Gaussian_SSIM",
                    "Sobel_PSNR_dB","Sobel_SSIM"])
        gd = {n:(p,s) for n,p,s in gauss_rows}
        sd = {n:(p,s) for n,p,s in sobel_rows}
        for d in chosen:
            gp,gs = gd.get(d,("",""))
            sp,ss = sd.get(d,("",""))
            w.writerow([d,gp,gs,sp,ss])
    print(f"[CSV saved → {csv_p}]\n")


def _load_gray(path):
    if path.lower().endswith(('.tif','.tiff')):
        img = tifffile.imread(path)
    else:
        img = np.array(Image.open(path))
    if img.ndim == 3:
        img = (0.2989*img[...,0]+0.5870*img[...,1]+0.1140*img[...,2]).astype(np.uint8)
    elif img.dtype != np.uint8:
        img = ((img.astype(np.float64)/img.max())*255).astype(np.uint8)
    return img

def _save(arr, path):
    Image.fromarray(arr).save(path)


if __name__ == "__main__":
    main()