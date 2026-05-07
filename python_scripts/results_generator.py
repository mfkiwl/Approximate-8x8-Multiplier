# results_generator.py

import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
from skimage.metrics import peak_signal_noise_ratio as compute_psnr
from skimage.metrics import structural_similarity as compute_ssim
import os
import csv

# CONFIGURATION
BASE_PATH      = "C:/Users/ankit/8x8 Multiplier"
IMAGES_FOLDER  = f"{BASE_PATH}/images"
SIM_OUTPUT     = f"{BASE_PATH}/sim_output"
SIM_INPUT      = f"{BASE_PATH}/sim_input"
RESULTS_FOLDER = f"{BASE_PATH}/results"

os.makedirs(f"{RESULTS_FOLDER}/gaussian",  exist_ok=True)
os.makedirs(f"{RESULTS_FOLDER}/sobel",     exist_ok=True)
os.makedirs(f"{RESULTS_FOLDER}/combined",  exist_ok=True)


# STEP 1: READ IMAGE INFO
info_file = f"{SIM_INPUT}/image_info.txt"
if not os.path.exists(info_file):
    print("ERROR: image_info.txt not found!")
    print("Please run prepare_image.py first.")
    exit(1)

image_info = {}
with open(info_file, 'r') as f:
    for line in f:
        line = line.strip()
        if "=" in line:
            key, val = line.split("=", 1)
            image_info[key] = val

GAUSSIAN_IMAGE  = image_info["GAUSSIAN_IMAGE"]
GAUSSIAN_WIDTH  = int(image_info["GAUSSIAN_WIDTH"])
GAUSSIAN_HEIGHT = int(image_info["GAUSSIAN_HEIGHT"])
SOBEL_IMAGE     = image_info["SOBEL_IMAGE"]
SOBEL_WIDTH     = int(image_info["SOBEL_WIDTH"])
SOBEL_HEIGHT    = int(image_info["SOBEL_HEIGHT"])

GAUSS_OUT_W = GAUSSIAN_WIDTH  - 2
GAUSS_OUT_H = GAUSSIAN_HEIGHT - 2
SOBEL_OUT_W = SOBEL_WIDTH     - 2
SOBEL_OUT_H = SOBEL_HEIGHT    - 2

print("="*60)
print("IMAGE INFORMATION")
print("="*60)
print(f"Gaussian : {GAUSSIAN_IMAGE} ({GAUSSIAN_WIDTH}x{GAUSSIAN_HEIGHT})")
print(f"Sobel    : {SOBEL_IMAGE} ({SOBEL_WIDTH}x{SOBEL_HEIGHT})")
print(f"Gaussian output size : {GAUSS_OUT_W}x{GAUSS_OUT_H}")
print(f"Sobel output size    : {SOBEL_OUT_W}x{SOBEL_OUT_H}")
print("="*60)


# STEP 2: LOAD ORIGINAL IMAGES

gaussian_orig = np.array(
    Image.open(f"{IMAGES_FOLDER}/{GAUSSIAN_IMAGE}").convert("L")
)
sobel_orig = np.array(
    Image.open(f"{IMAGES_FOLDER}/{SOBEL_IMAGE}").convert("L")
)

# Crop to match filtered output size
gaussian_crop = gaussian_orig[2:GAUSS_OUT_H+2, 2:GAUSS_OUT_W+2]
sobel_crop    = sobel_orig[2:SOBEL_OUT_H+2,    2:SOBEL_OUT_W+2]

# HELPER FUNCTIONS

def read_txt_file(filepath):
    pixels = []
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if line.isdigit():
                pixels.append(int(line))
    return pixels

def reconstruct_image(pixels, width, height):
    expected = width * height
    if len(pixels) < expected:
        print(f"  WARNING: Got {len(pixels)}, "
              f"expected {expected}. Padding.")
        pixels = pixels + [0] * (expected - len(pixels))
    elif len(pixels) > expected:
        pixels = pixels[:expected]
    arr = np.array(pixels, dtype=np.uint8)
    return arr.reshape(height, width)

def get_metrics(reference, filtered):
    if np.array_equal(reference, filtered):
        return float('inf'), 1.0
    psnr = compute_psnr(reference, filtered, data_range=255)
    s    = compute_ssim(reference, filtered, data_range=255)
    return psnr, s

def format_psnr(psnr):
    if psnr == float('inf'):
        return "inf"
    return f"{psnr:.2f}"

# STEP 3: LOAD REFERENCE IMAGES FOR PSNR/SSIM
#
# GAUSSIAN reference = original image
# SOBEL reference    = exact multiplier sobel output
# This matches exactly how paper computes metrics

# NEW - gaussian uses exact output too
gauss_exact_file = f"{SIM_OUTPUT}/gaussian_multiplier_8x8.txt"
sobel_exact_file = f"{SIM_OUTPUT}/sobel_multiplier_8x8.txt"

if os.path.exists(gauss_exact_file):
    print("Gaussian reference : gaussian_multiplier_8x8.txt found!")
    gauss_exact_pixels = read_txt_file(gauss_exact_file)
    gauss_reference    = reconstruct_image(
        gauss_exact_pixels, GAUSS_OUT_W, GAUSS_OUT_H
    )
else:
    print("WARNING: gaussian_exact.txt NOT found!")
    print("Run exact multiplier simulation first")
    gauss_reference = gaussian_crop

if os.path.exists(sobel_exact_file):
    print("Sobel reference    : sobel_multiplier_8x8.txt found!")
    sobel_exact_pixels = read_txt_file(sobel_exact_file)
    sobel_reference    = reconstruct_image(
        sobel_exact_pixels, SOBEL_OUT_W, SOBEL_OUT_H
    )
else:
    print("WARNING: sobel_exact.txt NOT found!")
    print("Run exact multiplier simulation first")
    sobel_reference = sobel_crop


# ═══════════════════════════════════════════════════════════
# STEP 4: FIND ALL SIMULATION OUTPUT FILES
# ═══════════════════════════════════════════════════════════
all_files = os.listdir(SIM_OUTPUT)

gaussian_files = sorted([
    f for f in all_files
    if f.startswith("gaussian_")
    and f.endswith(".txt")
    and f != "gaussian_exact.txt"  # skip exact reference
])
sobel_files = sorted([
    f for f in all_files
    if f.startswith("sobel_")
    and f.endswith(".txt")
    and f != "sobel_exact.txt"     # skip exact reference
])

gaussian_designs = [
    f.replace("gaussian_", "").replace(".txt", "")
    for f in gaussian_files
]
sobel_designs = [
    f.replace("sobel_", "").replace(".txt", "")
    for f in sobel_files
]

print(f"\nFound {len(gaussian_files)} gaussian files:")
for d in gaussian_designs:
    print(f"  → {d}")
print(f"\nFound {len(sobel_files)} sobel files:")
for d in sobel_designs:
    print(f"  → {d}")

# ═══════════════════════════════════════════════════════════
# STEP 5: PROCESS ALL FILES
# ═══════════════════════════════════════════════════════════
gaussian_results = []
sobel_results    = []

# ── Process Gaussian ──────────────────────────────────────
print("\n" + "="*60)
print("PROCESSING GAUSSIAN FILES")
print("Reference: exact gaussian output")
print("="*60)

for design in gaussian_designs:
    print(f"\n  Design: {design}")
    filepath = f"{SIM_OUTPUT}/gaussian_{design}.txt"

    pixels   = read_txt_file(filepath)
    filtered = reconstruct_image(
        pixels, GAUSS_OUT_W, GAUSS_OUT_H
    )

    # Compare vs original image
    psnr, ssim = get_metrics(gauss_reference, filtered)

    print(f"  PSNR : {format_psnr(psnr)} dB")
    print(f"  SSIM : {ssim*100:.3f} %")

    Image.fromarray(filtered).save(
        f"{RESULTS_FOLDER}/gaussian/{design}_filtered.png"
    )

    gaussian_results.append({
        "design"  : design,
        "filtered": filtered,
        "psnr"    : psnr,
        "ssim"    : ssim
    })

# ── Process Sobel ─────────────────────────────────────────
print("\n" + "="*60)
print("PROCESSING SOBEL FILES")
print("Reference: exact multiplier output")
print("="*60)

for design in sobel_designs:
    print(f"\n  Design: {design}")
    filepath = f"{SIM_OUTPUT}/sobel_{design}.txt"

    pixels   = read_txt_file(filepath)
    filtered = reconstruct_image(
        pixels, SOBEL_OUT_W, SOBEL_OUT_H
    )

    # Compare vs exact sobel output
    psnr, ssim = get_metrics(sobel_reference, filtered)

    print(f"  PSNR : {format_psnr(psnr)} dB")
    print(f"  SSIM : {ssim*100:.3f} %")

    Image.fromarray(filtered).save(
        f"{RESULTS_FOLDER}/sobel/{design}_filtered.png"
    )

    sobel_results.append({
        "design"  : design,
        "filtered": filtered,
        "psnr"    : psnr,
        "ssim"    : ssim
    })

# ═══════════════════════════════════════════════════════════
# STEP 6: SAVE METRICS CSV
# ═══════════════════════════════════════════════════════════
print("\n" + "="*60)
print("SAVING METRICS CSV")
print("="*60)

all_designs = sorted(set(
    [r["design"] for r in gaussian_results] +
    [r["design"] for r in sobel_results]
))

csv_rows = []
for design in all_designs:
    row = {"Design": design}

    g = next(
        (r for r in gaussian_results
         if r["design"] == design), None
    )
    if g:
        row["Gaussian_PSNR(dB)"] = (
            "inf" if g["psnr"] == float('inf')
            else round(g["psnr"], 4)
        )
        row["Gaussian_SSIM(%)"] = round(g["ssim"]*100, 4)
    else:
        row["Gaussian_PSNR(dB)"] = "N/A"
        row["Gaussian_SSIM(%)"]  = "N/A"

    s = next(
        (r for r in sobel_results
         if r["design"] == design), None
    )
    if s:
        row["Sobel_PSNR(dB)"] = (
            "inf" if s["psnr"] == float('inf')
            else round(s["psnr"], 4)
        )
        row["Sobel_SSIM(%)"] = round(s["ssim"]*100, 4)
    else:
        row["Sobel_PSNR(dB)"] = "N/A"
        row["Sobel_SSIM(%)"]  = "N/A"

    csv_rows.append(row)

csv_path = f"{RESULTS_FOLDER}/metrics.csv"
with open(csv_path, 'w', newline='') as f:
    fieldnames = [
        "Design",
        "Gaussian_PSNR(dB)", "Gaussian_SSIM(%)",
        "Sobel_PSNR(dB)",    "Sobel_SSIM(%)"
    ]
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(csv_rows)

print(f"Saved: {csv_path}")
print("\nMETRICS TABLE:")
print(f"{'Design':<20} {'G-PSNR':>10} {'G-SSIM':>10}"
      f" {'S-PSNR':>10} {'S-SSIM':>10}")
print("-"*65)
for row in csv_rows:
    print(
        f"{row['Design']:<20}"
        f" {str(row['Gaussian_PSNR(dB)']):>10}"
        f" {str(row['Gaussian_SSIM(%)']):>10}"
        f" {str(row['Sobel_PSNR(dB)']):>10}"
        f" {str(row['Sobel_SSIM(%)']):>10}"
    )

# ═══════════════════════════════════════════════════════════
# STEP 7: COMBINED GAUSSIAN FIGURE
# ═══════════════════════════════════════════════════════════
if len(gaussian_results) > 0:
    n = len(gaussian_results)
    fig, axes = plt.subplots(
        1, n+1, figsize=(4*(n+1), 4)
    )

    axes[0].imshow(gaussian_crop, cmap='gray',
                   vmin=0, vmax=255)
    axes[0].set_title(
        f"Original\n{GAUSSIAN_IMAGE}",
        fontsize=9, fontweight='bold'
    )
    axes[0].axis('off')

    for idx, result in enumerate(gaussian_results):
        col      = idx + 1
        psnr_str = format_psnr(result["psnr"])
        axes[col].imshow(result["filtered"],
                         cmap='gray', vmin=0, vmax=255)
        axes[col].set_title(
            f"{result['design']}\n"
            f"PSNR={psnr_str}dB\n"
            f"SSIM={result['ssim']*100:.2f}%",
            fontsize=8
        )
        axes[col].axis('off')

    plt.suptitle(
        "Gaussian Smoothing Results",
        fontsize=13, fontweight='bold', y=1.02
    )
    plt.tight_layout()
    path = f"{RESULTS_FOLDER}/combined/gaussian_all.png"
    plt.savefig(path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\nSaved: {path}")

# ═══════════════════════════════════════════════════════════
# STEP 8: COMBINED SOBEL FIGURE
# ═══════════════════════════════════════════════════════════
if len(sobel_results) > 0:
    n = len(sobel_results)
    fig, axes = plt.subplots(
        1, n+1, figsize=(4*(n+1), 4)
    )

    axes[0].imshow(sobel_crop, cmap='gray',
                   vmin=0, vmax=255)
    axes[0].set_title(
        f"Original\n{SOBEL_IMAGE}",
        fontsize=9, fontweight='bold'
    )
    axes[0].axis('off')

    for idx, result in enumerate(sobel_results):
        col      = idx + 1
        psnr_str = format_psnr(result["psnr"])
        axes[col].imshow(result["filtered"],
                         cmap='gray', vmin=0, vmax=255)
        axes[col].set_title(
            f"{result['design']}\n"
            f"PSNR={psnr_str}dB\n"
            f"SSIM={result['ssim']*100:.2f}%",
            fontsize=8
        )
        axes[col].axis('off')

    plt.suptitle(
        "Sobel Edge Detection Results",
        fontsize=13, fontweight='bold', y=1.02
    )
    plt.tight_layout()
    path = f"{RESULTS_FOLDER}/combined/sobel_all.png"
    plt.savefig(path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {path}")

# ═══════════════════════════════════════════════════════════
# STEP 9: COMBINED BOTH ROWS FIGURE
# ═══════════════════════════════════════════════════════════
if len(gaussian_results) > 0 and len(sobel_results) > 0:
    n_cols = max(len(gaussian_results),
                 len(sobel_results)) + 1

    fig, axes = plt.subplots(
        2, n_cols, figsize=(4*n_cols, 8)
    )

    # Row 0: Gaussian
    axes[0][0].imshow(gaussian_crop, cmap='gray',
                      vmin=0, vmax=255)
    axes[0][0].set_title(
        f"Original\n{GAUSSIAN_IMAGE}",
        fontsize=9, fontweight='bold'
    )
    axes[0][0].axis('off')

    for idx, result in enumerate(gaussian_results):
        col      = idx + 1
        psnr_str = format_psnr(result["psnr"])
        axes[0][col].imshow(
            result["filtered"], cmap='gray',
            vmin=0, vmax=255
        )
        axes[0][col].set_title(
            f"{result['design']}\n"
            f"PSNR={psnr_str}dB\n"
            f"SSIM={result['ssim']*100:.2f}%",
            fontsize=8
        )
        axes[0][col].axis('off')

    for col in range(len(gaussian_results)+1, n_cols):
        axes[0][col].axis('off')

    # Row 1: Sobel
    axes[1][0].imshow(sobel_crop, cmap='gray',
                      vmin=0, vmax=255)
    axes[1][0].set_title(
        f"Original\n{SOBEL_IMAGE}",
        fontsize=9, fontweight='bold'
    )
    axes[1][0].axis('off')

    for idx, result in enumerate(sobel_results):
        col      = idx + 1
        psnr_str = format_psnr(result["psnr"])
        axes[1][col].imshow(
            result["filtered"], cmap='gray',
            vmin=0, vmax=255
        )
        axes[1][col].set_title(
            f"{result['design']}\n"
            f"PSNR={psnr_str}dB\n"
            f"SSIM={result['ssim']*100:.2f}%",
            fontsize=8
        )
        axes[1][col].axis('off')

    for col in range(len(sobel_results)+1, n_cols):
        axes[1][col].axis('off')

    axes[0][0].set_ylabel(
        "Gaussian Smoothing",
        fontsize=11, fontweight='bold'
    )
    axes[1][0].set_ylabel(
        "Sobel Edge Detection",
        fontsize=11, fontweight='bold'
    )

    plt.suptitle(
        "Image Processing Results\n"
        "Row 1: Gaussian Smoothing | "
        "Row 2: Sobel Edge Detection",
        fontsize=12, fontweight='bold'
    )
    plt.tight_layout()
    path = f"{RESULTS_FOLDER}/combined/all_results.png"
    plt.savefig(path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {path}")

print("\n" + "="*60)
print("ALL DONE!")
print("="*60)
print(f"Results folder: {RESULTS_FOLDER}")