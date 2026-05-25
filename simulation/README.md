# Simulations

Behavioral simulation files for `tb_qr_eigen_top` in Xilinx Vivado XSim.

---

## Test Matrix (`simulation_matrix_output.txt`)

The testbench loads the following 5×5 symmetric positive-definite matrix:

```
n = 5
A = [ 8.0   1.0  -1.0   0.0   0.0 ]
    [ 1.0   6.0   2.0  -1.0   0.0 ]
    [-1.0   2.0   4.0   1.0  -1.0 ]
    [ 0.0  -1.0   1.0   5.0   2.0 ]
    [ 0.0   0.0  -1.0   2.0   7.0 ]
```

Expected eigenvalues (reference from MATLAB/NumPy):
```
λ ≈ { 9.87, 7.21, 5.43, 3.12, 1.47 }   (approximate)
```

---

## Running the Simulation

```tcl
# In Vivado Tcl Console after opening project_6.xpr:
launch_simulation -simset sim_1 -mode behavioral
run all
```

Or via GUI: **Flow → Run Simulation → Run Behavioral Simulation**

---

## Simulation Script (`tb_qr_eigen_top_xsim.tcl`)

The XSim TCL script sets up waveform logging for all key signals:
- FSM state register
- Matrix element outputs
- Convergence flag
- Iteration counter
- Eigenvalue outputs

---

## Expected Simulation Behaviour

1. Reset deasserted → FSM enters `S_LOAD`
2. Matrix loaded from `simulation_matrix_output.txt`
3. QR iterations begin: observe subdiagonal elements decreasing
4. Convergence flag asserted when `max|Ak[i,i-1]| < 1e-8`
5. Eigenvalues readable on output bus
