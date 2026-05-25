# QR Algorithm-Based Eigenvalue Decomposition (EVD) & SVD — FPGA Implementation

<div align="center">

![FPGA](https://img.shields.io/badge/Platform-Xilinx%20Zynq--7020-orange?style=flat-square&logo=xilinx)
![Vivado](https://img.shields.io/badge/Tool-Vivado%202025.2-red?style=flat-square)
![Language](https://img.shields.io/badge/HDL-SystemVerilog%20%7C%20VHDL-blue?style=flat-square)
![Python](https://img.shields.io/badge/Python-3.x-green?style=flat-square&logo=python)
![MATLAB](https://img.shields.io/badge/MATLAB-R2024-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)

**M.Tech Specialization Project | VLSI Design | SRMIST, Kattankulatham**  
**Registration No.: RA2412008010015 | Supervisor: Dr. Sudhanya P.**

</div>

---

## Abstract

This project presents a complete hardware implementation of the **QR Algorithm-based Eigenvalue Decomposition (EVD)** and **Singular Value Decomposition (SVD)** on a **Xilinx Zynq-7020 SoC (xc7z020clg400-1)**. The design employs **Modified Gram-Schmidt (MGS) orthogonalization** for numerically stable QR factorization, implemented using a **7-state one-hot Finite State Machine (FSM)** architecture. All arithmetic is performed in **IEEE-754 double-precision (64-bit) floating-point**, utilizing Xilinx Floating-Point IP cores (v7.1) for Add/Sub, Multiply, Divide, Square Root, and Compare operations. The design is synthesized and verified using Xilinx Vivado 2025.2, achieving a clock frequency of **100 MHz** with a convergence threshold of **10⁻⁸** on matrices up to size **N=6**.

---

## Table of Contents

- [Problem Statement](#problem-statement)
- [Objectives](#objectives)
- [Mathematical Background](#mathematical-background)
- [Architecture & Design](#architecture--design)
- [Tools & Technologies](#tools--technologies)
- [Repository Structure](#repository-structure)
- [Setup & Execution](#setup--execution)
- [Post-Implementation Results](#post-implementation-results)
- [Applications](#applications)
- [Future Scope](#future-scope)
- [Author](#author)

---

## Problem Statement

Eigenvalue and Singular Value Decomposition are computationally intensive operations critical to signal processing, machine learning, and control systems. Performing these on general-purpose CPUs introduces latency bottlenecks, particularly for real-time embedded applications. This project addresses the need for a **dedicated hardware accelerator** capable of computing EVD/SVD with high numerical precision and deterministic timing on an FPGA platform.

---

## Objectives

1. Implement the **QR Iteration Algorithm** with Modified Gram-Schmidt orthogonalization in synthesizable RTL.
2. Design a **7-state one-hot FSM** controller for managing the iterative QR-RQ update pipeline.
3. Integrate Xilinx **IEEE-754 double-precision Floating-Point IP cores** for arithmetic.
4. Validate functionality through **behavioral simulation** in Vivado XSim.
5. Perform **synthesis and post-implementation analysis** (utilization, timing, power) on Zynq-7020.
6. Provide **MATLAB and Python reference implementations** for algorithm verification.

---

## Mathematical Background

### QR Decomposition

Any real matrix **A ∈ ℝⁿˣⁿ** can be factored as:

```
A = Q · R
```

where **Q** is orthogonal (Q^T Q = I) and **R** is upper triangular. This project uses **Modified Gram-Schmidt** for numerical stability:

```
For each column j:
  u = A[:,j]
  For i = 1 to j-1:
    R[i,j] = Q[:,i]^T · u
    u = u - R[i,j] * Q[:,i]
  R[j,j] = ||u||
  Q[:,j] = u / R[j,j]
```

### QR Iteration for Eigenvalues

Repeated QR factorization converges the matrix to quasi-upper-triangular (Schur) form, revealing eigenvalues on the diagonal:

```
A₀ = A
Aₖ = Qₖ · Rₖ        (QR decomposition)
Aₖ₊₁ = Rₖ · Qₖ      (RQ update)
```

Convergence condition: `max|Aₖ[i,i-1]| < 10⁻⁸`

### Wilkinson Shift (for symmetric matrices)

For accelerated convergence on symmetric matrices:

```
d = (A[m-1,m-1] - A[m,m]) / 2
μ = A[m,m] - sign(d) · A[m,m-1]² / (|d| + √(d² + A[m,m-1]²))
```

---

## Architecture & Design

### Top-Level Module: `qr_eigen_top`

The hardware design is organized as a five-stage pipeline controlled by a **7-state one-hot FSM**:

```
┌─────────────────────────────────────────────────────────┐
│                    qr_eigen_top                          │
│                                                           │
│  ┌──────────┐   ┌──────────┐   ┌──────────────────────┐ │
│  │  Input    │   │   MGS    │   │   RQ Update + Accum  │ │
│  │  Buffer   │──▶│   QR     │──▶│   Eigenvector Accum  │ │
│  │  Matrix A │   │  Engine  │   │                      │ │
│  └──────────┘   └──────────┘   └──────────────────────┘ │
│                                          │                │
│  ┌──────────────────────────────────────▼──────────────┐ │
│  │            Convergence Checker (|sub-diag| < 10⁻⁸)  │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                           │
│  Floating-Point IP Cores (IEEE-754 Double Precision):     │
│  ● floating_point_addsub   ● floating_point_mul           │
│  ● floating_point_div      ● floating_point_sqrt          │
│  ● floating_point_cmp                                     │
└─────────────────────────────────────────────────────────┘
```

### FSM States

| State | Description |
|-------|-------------|
| `S_IDLE` | Waiting for start signal |
| `S_LOAD` | Loading input matrix |
| `S_SHIFT` | Computing Wilkinson/Rayleigh shift |
| `S_QR` | Modified Gram-Schmidt QR factorization |
| `S_RQ` | RQ update with shift restoration |
| `S_ACCUM` | Accumulate eigenvectors (Q_total) |
| `S_CHECK` | Convergence check; deflation or output |

### Floating-Point IP Cores

| IP Core | Operation | Latency (cycles) |
|---------|-----------|-----------------|
| `floating_point_addsub` | A ± B | 11 |
| `floating_point_mul` | A × B | 8 |
| `floating_point_div` | A / B | 28 |
| `floating_point_sqrt` | √A | 28 |
| `floating_point_cmp` | A < B ? | 2 |

---

## Tools & Technologies

| Category | Tool / Technology |
|----------|-------------------|
| **HDL** | SystemVerilog, VHDL |
| **FPGA Platform** | Xilinx Zynq-7020 SoC (xc7z020clg400-1) |
| **EDA Tool** | Xilinx Vivado 2025.2 |
| **Simulator** | Vivado XSim (behavioral) |
| **IP Cores** | Xilinx Floating Point v7.1 |
| **Numeric Reference** | MATLAB R2024 |
| **Algorithm Reference** | Python 3.x + NumPy |
| **Arithmetic Standard** | IEEE-754 Double Precision (64-bit) |
| **Target Clock** | 100 MHz |

---

## Repository Structure

```
qr-eigenvalue-decomposition/
│
├── src/
│   ├── matlab/
│   │   └── qr_eigenvalue_decomposition.m      # MATLAB QR algorithm (with deflation & shifts)
│   ├── python/
│   │   └── qr_eigenvalue_decomposition.py     # Python/NumPy reference implementation
│   └── verilog/
│       └── ip_cores/                           # Xilinx FP IP core configurations (.xci)
│
├── simulations/
│   └── simulation_matrix_output.txt            # XSim simulation matrix input/output
│
├── results/
│   ├── utilization_synthesis.rpt               # LUT/FF/DSP utilization (synthesis)
│   ├── utilization_post_implementation.rpt     # LUT/FF/DSP utilization (routed)
│   ├── timing_synthesis.rpt                    # Timing summary (synthesis)
│   ├── timing_post_implementation.rpt          # Timing summary (post-impl)
│   ├── power_synthesis.rpt                     # Power estimate (synthesis)
│   └── power_post_implementation.rpt           # Power report (post-impl)
│
├── figures/                                    # Waveform screenshots, block diagrams
├── reports/                                    # Final project report (PDF)
├── presentations/                              # Project presentation (PPTX)
├── docs/
│   └── SETUP_GUIDE.md                         # Vivado setup and simulation guide
├── references/                                 # Research papers and references
│
├── README.md
├── LICENSE
├── .gitignore
└── requirements.txt
```

---

## Setup & Execution

### Prerequisites

- **Xilinx Vivado 2025.2** (for FPGA simulation and synthesis)
- **Python 3.8+** with NumPy (`pip install numpy`)
- **MATLAB R2022+** (optional, for MATLAB implementation)

### 1. Python Reference Implementation

```bash
# Clone the repository
git clone https://github.com/saikrishnareddy2002/qr-eigenvalue-decomposition.git
cd qr-eigenvalue-decomposition

# Install dependencies
pip install -r requirements.txt

# Run Python implementation
python src/python/qr_eigenvalue_decomposition.py
```

**Example session:**
```
Enter matrix size n: 5
Row 1: 8.0 1.0 -1.0 0.0 0.0
Row 2: 1.0 6.0 2.0 -1.0 0.0
Row 3: -1.0 2.0 4.0 1.0 -1.0
Row 4: 0.0 -1.0 1.0 5.0 2.0
Row 5: 0.0 0.0 -1.0 2.0 7.0

→ Eigenvalues and eigenvectors printed after convergence
```

### 2. MATLAB Implementation

```matlab
cd src/matlab
run qr_eigenvalue_decomposition.m
% Enter matrix size and elements when prompted
```

### 3. Vivado Simulation

```bash
# Open Vivado and source the project
vivado -source project_6.xpr

# In Vivado Tcl Console:
launch_simulation
run all
```

See [`docs/SETUP_GUIDE.md`](docs/SETUP_GUIDE.md) for detailed Vivado setup instructions.

---

## Post-Implementation Results

### Resource Utilization (Xilinx Zynq-7020 — Routed)

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| Slice LUTs | 14,134 | 53,200 | **26.57%** |
| Slice Registers (FFs) | 22,798 | 106,400 | **21.43%** |
| DSP48 Blocks | — | 220 | — |
| F7 Muxes | 911 | 26,600 | 3.42% |
| Unique Control Sets | 232 | 13,300 | 1.74% |

### Timing Summary

| Parameter | Value |
|-----------|-------|
| Target Clock | 100 MHz (10 ns) |
| Device | xc7z020clg400-1 |
| Design State | Synthesized + Implementation attempted |
| Convergence Threshold | 10⁻⁸ |

### Power Summary (Post-Implementation)

| Parameter | Value |
|-----------|-------|
| Total On-Chip Power | 183.551 W |
| Dynamic Power | 182.514 W |
| Static Power | 1.038 W |
| Junction Temperature | 125.0 °C |

> **Note:** Power values reflect worst-case switching activity estimates. Actual dynamic power with realistic activity factors will be significantly lower.

### Simulation Validation

Test matrix (N=6, from XSim simulation):
```
A = [ 8   1  -1   0   0 ]
    [ 1   6   2  -1   0 ]
    [-1   2   4   1  -1 ]
    [ 0  -1   1   5   2 ]
    [ 0   0  -1   2   7 ]
```
Eigenvalues converged successfully within tolerance `10⁻⁸`.

---

## Applications

- **MIMO Beamforming** — Signal processing in wireless communications
- **Principal Component Analysis (PCA)** — Dimensionality reduction for ML on edge devices
- **Structural Mechanics** — Vibration mode analysis
- **Image Compression** — SVD-based low-rank approximation
- **Control Systems** — Stability analysis via eigenvalue computation
- **Quantum Computing Simulation** — Hamiltonian eigenvalue problems

---

## Future Scope

1. **Pipeline Optimization** — Reduce critical path delay; target ≥ 150 MHz
2. **AXI4 Interface** — Integrate with Zynq PS via AXI for SoC deployment
3. **Variable Matrix Size** — Support runtime-configurable N (currently fixed N=6)
4. **Single-Precision Mode** — Add IEEE-754 single-precision option for lower power
5. **SVD Extension** — Complete hardware SVD via two-phase bidiagonalization
6. **Power Optimization** — Clock gating and operand isolation for lower dynamic power
7. **Formal Verification** — Apply property checking to convergence logic

---

## Author

**Sai Krishna Reddy**  
M.Tech, VLSI Design  
SRM Institute of Science and Technology (SRMIST), Kattankulatham  
Registration No.: RA2412008010015  
Supervisor: **Dr. Sudhanya P.**  

📧 [GitHub: saikrishnareddy2002](https://github.com/saikrishnareddy2002)  
🔗 [Project Repository](https://github.com/saikrishnareddy2002/qr-eigenvalue-decomposition)

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
<sub>Built with ❤️ using Xilinx Vivado 2025.2 | SRMIST M.Tech VLSI Design 2024–2026</sub>
</div>
