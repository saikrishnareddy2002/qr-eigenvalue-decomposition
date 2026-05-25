# Xilinx Floating-Point IP Cores — Configuration Files

This folder contains the `.xci` IP configuration files for all five Xilinx Floating-Point v7.1 IP cores used in the `qr_eigen_top` design.

## IP Cores

| File | Function | Latency (cycles) | Standard |
|------|----------|-----------------|----------|
| `floating_point_addsub.xci` | Double-precision Add / Subtract | 11 | IEEE-754 |
| `floating_point_mul.xci` | Double-precision Multiply | 8 | IEEE-754 |
| `floating_point_div.xci` | Double-precision Divide | 28 | IEEE-754 |
| `floating_point_sqrt.xci` | Double-precision Square Root | 28 | IEEE-754 |
| `floating_point_cmp.xci` | Double-precision Compare | 2 | IEEE-754 |

## Regenerating IP Outputs

The generated HDL files (netlist, stub, OOC XDC) are excluded from version control via `.gitignore`. To regenerate them in Vivado:

```tcl
# In Vivado Tcl Console:
upgrade_ip [get_ips]
generate_target all [get_ips]
```

Or in the GUI: **Flow → Generate IP Output Products**

## Data Format

All cores operate on **IEEE-754 Double Precision (64-bit)**:
- 1 sign bit
- 11 exponent bits
- 52 mantissa bits (+ 1 implicit)
- Range: ±5×10⁻³²⁴ to ±1.8×10³⁰⁸

## Tool Version

Generated with **Xilinx Vivado 2025.2** (Build 6299465).
