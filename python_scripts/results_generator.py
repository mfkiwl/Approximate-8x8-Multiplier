# results_generator.py
# Does everything in one run:
# 1. Reads all txt files from sim_output
# 2. Reconstructs all images
# 3. Computes PSNR and SSIM for each
# 4. Saves individual filtered images
# 5. Saves individual comparison images
# 6. Saves one combined figure (all designs together)
# 7. Saves metrics.csv

import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
from skimage.metrics import peak_signal_noise_ratio as compute_psnr
from skimage.metrics import structural_similarity as compute_ssim
import os
import csv


# CONFIGURATION
# Only change BASE_PATH if your folder is different

BASE_PATH = "C:/Users/ankit/8x8 Multiplier"

# Folders
IMAGES_FOLDER  = f"{BASE_PATH}/images"
SIM_OUTPUT     = f"{BASE_PATH}/sim_output"
SIM_INPUT      = f"{BASE_PATH}/sim_input"
RESULTS_FOLDER = f"{BASE_PATH}/results"

# Create result folders
os.makedirs(f"{RESULTS_FOLDER}/gaussian",   exist_ok=True)
os.makedirs(f"{RESULTS_FOLDER}/sobel",      exist_ok=True)
os.makedirs(f"{RESULTS_FOLDER}/combined",   exist_ok=True)

# STEP 1: READ IMAGE INFO
# Written by prepare_image.py
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

# Extract dimensions
GAUSSIAN_IMAGE  = image_info["GAUSSIAN_IMAGE"]
GAUSSIAN_WIDTH  = int(image_info["GAUSSIAN_WIDTH"])
GAUSSIAN_HEIGHT = int(image_info["GAUSSIAN_HEIGHT"])
SOBEL_IMAGE     = image_info["SOBEL_IMAGE"]
SOBEL_WIDTH     = int(image_info["SOBEL_WIDTH"])
SOBEL_HEIGHT    = int(image_info["SOBEL_HEIGHT"])

# Output sizes after 3x3 filtering
GAUSS_OUT_W = GAUSSIAN_WIDTH  - 2
GAUSS_OUT_H = GAUSSIAN_HEIGHT - 2
SOBEL_OUT_W = SOBEL_WIDTH     - 2
SOBEL_OUT_H = SOBEL_HEIGHT    - 2

print("="*60)
print("IMAGE INFORMATION")
print("="*60)
print(f"Gaussian image : {GAUSSIAN_IMAGE}")
print(f"  Input size   : {GAUSSIAN_WIDTH} x {GAUSSIAN_HEIGHT}")
print(f"  Output size  : {GAUSS_OUT_W} x {GAUSS_OUT_H}")
print(f"Sobel image    : {SOBEL_IMAGE}")
print(f"  Input size   : {SOBEL_WIDTH} x {SOBEL_HEIGHT}")
print(f"  Output size  : {SOBEL_OUT_W} x {SOBEL_OUT_H}")
print("="*60)

# STEP 2: LOAD ORIGINAL IMAGES

gaussian_orig = np.array(
    Image.open(f"{IMAGES_FOLDER}/{GAUSSIAN_IMAGE}").convert("L")
)
sobel_orig = np.array(
    Image.open(f"{IMAGES_FOLDER}/{SOBEL_IMAGE}").convert("L")
)

# Crop originals to match filtered output size
# 3x3 filter loses 1 pixel border on each side
gaussian_crop = gaussian_orig[1:GAUSS_OUT_H+1, 1:GAUSS_OUT_W+1]
sobel_crop    = sobel_orig[1:SOBEL_OUT_H+1,    1:SOBEL_OUT_W+1]


# HELPER FUNCTIONS

def read_txt_file(filepath):
    """Read pixel values from Vivado output txt file"""
    pixels = []
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if line.isdigit():
                pixels.append(int(line))
    return pixels

def reconstruct_image(pixels, width, height):
    """Reshape flat pixel list into 2D image array"""
    expected = width * height
    if len(pixels) < expected:
        print(f"  WARNING: Got {len(pixels)} pixels,"
              f" expected {expected}. Padding with 0.")
        pixels = pixels + [0] * (expected - len(pixels))
    elif len(pixels) > expected:
        pixels = pixels[:expected]
    arr = np.array(pixels, dtype=np.uint8)
    return arr.reshape(height, width)

def get_metrics(original, filtered):
    """Compute PSNR and SSIM"""
    if np.array_equal(original, filtered):
        return float('inf'), 1.0
    psnr = compute_psnr(original, filtered, data_range=255)
    s    = compute_ssim(original, filtered, data_range=255)
    return psnr, s

def format_psnr(psnr):
    """Format PSNR for display"""
    if psnr == float('inf'):
        return "inf"
    return f"{psnr:.2f}"


# STEP 3: FIND ALL SIMULATION OUTPUT FILES
all_files = os.listdir(SIM_OUTPUT)

gaussian_files = sorted([
    f for f in all_files
    if f.startswith("gaussian_") and f.endswith(".txt")
])
sobel_files = sorted([
    f for f in all_files
    if f.startswith("sobel_") and f.endswith(".txt")
])

# Extract design names
gaussian_designs = [
    f.replace("gaussian_", "").replace(".txt", "")
    for f in gaussian_files
]
sobel_designs = [
    f.replace("sobel_", "").replace(".txt", "")
    for f in sobel_files
]

print(f"\nFound {len(gaussian_files)} gaussian output files:")
for d in gaussian_designs:
    print(f"  → {d}")

print(f"\nFound {len(sobel_files)} sobel output files:")
for d in sobel_designs:
    print(f"  → {d}")

# STEP 4: PROCESS ALL FILES
# Reconstruct images and compute metrics

# Store results for CSV and combined figure
gaussian_results = []
sobel_results    = []

# Process Gaussian
print("\n" + "="*60)
print("PROCESSING GAUSSIAN FILES")
print("="*60)

for design in gaussian_designs:
    print(f"\n  Design: {design}")
    filepath = f"{SIM_OUTPUT}/gaussian_{design}.txt"

    pixels      = read_txt_file(filepath)
    filtered    = reconstruct_image(
        pixels, GAUSS_OUT_W, GAUSS_OUT_H
    )
    psnr, ssim  = get_metrics(gaussian_crop, filtered)

    print(f"  PSNR : {format_psnr(psnr)} dB")
    print(f"  SSIM : {ssim*100:.3f} %")

    # Save filtered image
    Image.fromarray(filtered).save(
        f"{RESULTS_FOLDER}/gaussian/{design}_filtered.png"
    )

    # Store for later use
    gaussian_results.append({
        "design"  : design,
        "filtered": filtered,
        "psnr"    : psnr,
        "ssim"    : ssim
    })

# Process Sobel 
print("\n" + "="*60)
print("PROCESSING SOBEL FILES")
print("="*60)

for design in sobel_designs:
    print(f"\n  Design: {design}")
    filepath = f"{SIM_OUTPUT}/sobel_{design}.txt"

    pixels      = read_txt_file(filepath)
    filtered    = reconstruct_image(
        pixels, SOBEL_OUT_W, SOBEL_OUT_H
    )
    psnr, ssim  = get_metrics(sobel_crop, filtered)

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


# STEP 5: SAVE METRICS CSV

print("\n" + "="*60)
print("SAVING METRICS CSV")
print("="*60)

# Combine all designs
all_designs = set(
    [r["design"] for r in gaussian_results] +
    [r["design"] for r in sobel_results]
)

csv_rows = []
for design in sorted(all_designs):
    row = {"Design": design}

    # Gaussian metrics
    g = next(
        (r for r in gaussian_results if r["design"] == design),
        None
    )
    if g:
        row["Gaussian_PSNR(dB)"] = (
            "inf" if g["psnr"] == float('inf')
            else round(g["psnr"], 4)
        )
        row["Gaussian_SSIM(%)"] = round(g["ssim"] * 100, 4)
    else:
        row["Gaussian_PSNR(dB)"] = "N/A"
        row["Gaussian_SSIM(%)"]  = "N/A"

    # Sobel metrics
    s = next(
        (r for r in sobel_results if r["design"] == design),
        None
    )
    if s:
        row["Sobel_PSNR(dB)"] = (
            "inf" if s["psnr"] == float('inf')
            else round(s["psnr"], 4)
        )
        row["Sobel_SSIM(%)"] = round(s["ssim"] * 100, 4)
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

# Print table to console
print("\nMETRICS TABLE:")
print(f"{'Design':<20} {'G-PSNR':>10} {'G-SSIM':>10}"
      f" {'S-PSNR':>10} {'S-SSIM':>10}")
print("-"*62)
for row in csv_rows:
    print(
        f"{row['Design']:<20}"
        f" {str(row['Gaussian_PSNR(dB)']):>10}"
        f" {str(row['Gaussian_SSIM(%)']):>10}"
        f" {str(row['Sobel_PSNR(dB)']):>10}"
        f" {str(row['Sobel_SSIM(%)']):>10}"
    )


# STEP 6: COMBINED FIGURE FOR GAUSSIAN

print("\n" + "="*60)
print("GENERATING COMBINED FIGURES")
print("="*60)

if len(gaussian_results) > 0:
    n_designs = len(gaussian_results)

    # Figure has 2 rows:
    # Row 1: original + all filtered images
    # Row 2: PSNR and SSIM text for each
    fig, axes = plt.subplots(
        1, n_designs + 1,
        figsize=(4 * (n_designs + 1), 4)
    )

    # Column 0: original
    axes[0].imshow(gaussian_crop, cmap='gray',
                   vmin=0, vmax=255)
    axes[0].set_title(
        f"Original\n{GAUSSIAN_IMAGE}",
        fontsize=9, fontweight='bold'
    )
    axes[0].axis('off')

    # Remaining columns: each design
    for idx, result in enumerate(gaussian_results):
        col = idx + 1
        axes[col].imshow(
            result["filtered"], cmap='gray',
            vmin=0, vmax=255
        )
        psnr_str = format_psnr(result["psnr"])
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
    gauss_combined = f"{RESULTS_FOLDER}/combined/gaussian_all_designs.png"
    plt.savefig(gauss_combined, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {gauss_combined}")


# STEP 7: COMBINED FIGURE FOR SOBEL

if len(sobel_results) > 0:
    n_designs = len(sobel_results)

    fig, axes = plt.subplots(
        1, n_designs + 1,
        figsize=(4 * (n_designs + 1), 4)
    )

    # Column 0: original
    axes[0].imshow(sobel_crop, cmap='gray',
                   vmin=0, vmax=255)
    axes[0].set_title(
        f"Original\n{SOBEL_IMAGE}",
        fontsize=9, fontweight='bold'
    )
    axes[0].axis('off')

    # Remaining columns: each design
    for idx, result in enumerate(sobel_results):
        col = idx + 1
        axes[col].imshow(
            result["filtered"], cmap='gray',
            vmin=0, vmax=255
        )
        psnr_str = format_psnr(result["psnr"])
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
    sobel_combined = f"{RESULTS_FOLDER}/combined/sobel_all_designs.png"
    plt.savefig(sobel_combined, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {sobel_combined}")


# STEP 8: COMBINED FIGURE GAUSSIAN + SOBEL TOGETHER
# Row 1 = gaussian, Row 2 = sobel
# Like Figure 10 and 11 in the paper together

if len(gaussian_results) > 0 and len(sobel_results) > 0:

    # Use max designs for columns
    n_cols = max(len(gaussian_results),
                 len(sobel_results)) + 1

    fig, axes = plt.subplots(
        2, n_cols,
        figsize=(4 * n_cols, 8)
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
        col = idx + 1
        axes[0][col].imshow(
            result["filtered"], cmap='gray',
            vmin=0, vmax=255
        )
        psnr_str = format_psnr(result["psnr"])
        axes[0][col].set_title(
            f"{result['design']}\n"
            f"PSNR={psnr_str}dB\n"
            f"SSIM={result['ssim']*100:.2f}%",
            fontsize=8
        )
        axes[0][col].axis('off')

    # Hide unused gaussian columns
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
        col = idx + 1
        axes[1][col].imshow(
            result["filtered"], cmap='gray',
            vmin=0, vmax=255
        )
        psnr_str = format_psnr(result["psnr"])
        axes[1][col].set_title(
            f"{result['design']}\n"
            f"PSNR={psnr_str}dB\n"
            f"SSIM={result['ssim']*100:.2f}%",
            fontsize=8
        )
        axes[1][col].axis('off')

    # Hide unused sobel columns
    for col in range(len(sobel_results)+1, n_cols):
        axes[1][col].axis('off')

    # Row labels on left side
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
    both_combined = (
        f"{RESULTS_FOLDER}/combined/all_results_combined.png"
    )
    plt.savefig(both_combined, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {both_combined}")

# FINAL SUMMARY
print("\n" + "="*60)
print("ALL DONE!")
print("="*60)
print(f"\nFiles saved in: {RESULTS_FOLDER}")
print(f"\nIndividual filtered images:")
print(f"  {RESULTS_FOLDER}/gaussian/")
print(f"  {RESULTS_FOLDER}/sobel/")
print(f"\nCombined figures:")
print(f"  combined/gaussian_all_designs.png")
print(f"  combined/sobel_all_designs.png")
print(f"  combined/all_results_combined.png")
print(f"\nMetrics table:")
print(f"  results/metrics.csv  ← open in Excel")
print("="*60)