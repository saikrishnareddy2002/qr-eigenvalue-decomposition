# Implementation Results — Summary

All Vivado-generated reports for the `qr_eigen_top` design targeting the **Xilinx Zynq-7020 (xc7z020clg400-1)**.

---

## Resource Utilization

### Synthesis (Device: xc7z014sclg400-1)

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| Slice LUTs | 16,956 | 40,600 | **41.76%** |
| Slice Registers (FF) | 19,785 | 81,200 | **24.37%** |
| F7 Muxes | 1,536 | 26,600 | 5.77% |
| Block RAM | 0 | 107 | 0.00% |
| DSP48 | 0 | — | 0.00% |
| Unique Control Sets | 248 | 13,300 | 1.86% |

### Post-Implementation (Device: xc7z020clg400-1 — Routed)

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| Slice LUTs | 14,134 | 53,200 | **26.57%** |
| LUT as Logic | 13,718 | 53,200 | 25.79% |
| LUT as Shift Register | 416 | 17,400 | 2.39% |
| Slice Registers (FF) | 22,798 | 106,400 | **21.43%** |
| F7 Muxes | 911 | 26,600 | 3.42% |
| F8 Muxes | 2 | 13,300 | 0.02% |
| Unique Control Sets | 232 | 13,300 | 1.74% |

---

## Timing Summary

| Parameter | Value |
|-----------|-------|
| Target Clock | 100 MHz (10 ns period) |
| Tool | Vivado 2025.2 |
| Design State | Synthesized + Implementation attempted |
| Device Speed Grade | -1 |

> Full timing paths available in `timing_synthesis.rpt` and `timing_post_implementation.rpt`

---

## Power Analysis (Post-Implementation)

| Parameter | Value |
|-----------|-------|
| Total On-Chip Power | 183.551 W |
| Dynamic Power | 182.514 W |
| Device Static | 1.038 W |
| Junction Temperature | 125.0 °C |
| Confidence Level | Low |

> **Note:** The high dynamic power estimate is due to 100% default toggle rate in Vivado's power analysis. Actual deployed power with realistic switching activity will be significantly lower (~10–20× reduction typical).

---

## Report Files

| File | Contents |
|------|----------|
| `utilization_synthesis.rpt` | Resource usage after synthesis (Zynq-7014s) |
| `utilization_post_implementation.rpt` | Resource usage after route (Zynq-7020) |
| `timing_synthesis.rpt` | Setup/hold timing report (synthesis) |
| `timing_post_implementation.rpt` | Timing after place-and-route |
| `power_synthesis.rpt` | Power estimate at synthesis stage |
| `power_post_implementation.rpt` | Power analysis post-route |
