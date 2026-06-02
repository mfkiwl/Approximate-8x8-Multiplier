# Approximate 8×8 Multiplier for Energy-Efficient Image Processing

## Overview

This project focuses on the design and implementation of **approximate multipliers** aimed at improving hardware efficiency in error-tolerant applications such as image processing and neural networks. The work is inspired by recent IEEE research on energy-efficient multiplier architectures.

---

##  Objectives

* Design efficient **8×8 approximate multipliers** using different approximation techniques
* Reduce **power, area, and delay** while maintaining acceptable accuracy
* Analyze trade-offs between hardware performance and computational error
* Apply the design to **image processing tasks** and evaluate output quality

---

##  Techniques Used

* Partial Bit OR (PBO)-based approximation
* Recursive architecture using **8×4 multiplier decomposition**
* Hybrid designs using approximate compressors
* Carry truncation and logic simplification

---

##  Tools & Technologies

* **Verilog HDL** (Design & Implementation)
* **Xilinx Vivado** (Simulation & Synthesis)
* **ModelSim** (Functional Verification - optional)
* **FPGA (Planned)** for hardware validation

---

##  Evaluation Metrics

* Area, Power Consumption, Propagation Delay
* Power Delay Product (PDP)
* Mean Relative Error Distance (MRED)
* Image Quality Metrics: **PSNR, SSIM**

---

##  Applications

* Gaussian Image Smoothing
* Sobel Edge Detection
* Image Sharpening
* Deep Neural Network acceleration (planned)

---


##  Current Status

*  Literature study and architecture understanding
*  Verilog implementation started
*  Design optimization (area, power, delay)
*  Image processing integration
*  FPGA implementation and validation

---

##  Future Work

* Implement optimized architectures on FPGA
* Perform real-time image processing experiments
* Explore applications in deep learning accelerators

---

##  Reference

Based on IEEE research on energy-efficient approximate multipliers for image processing and neural networks.

---

##  Contributions

This is an ongoing project. I am doing this project with my peer Abhinav Tejpaul which is from the same institution (IIT Goa).
Irrespective of this anyone who would like to contribute is welcome to do so.

Contact: Email: ankitgkc@gmail.com , abhinav.tejpaul.23042@iitgoa.ac.in

---
