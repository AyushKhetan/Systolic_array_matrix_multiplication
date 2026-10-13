# Parameterized Systolic-Array Matrix Multiplier

A modular SystemVerilog implementation of a parameterized systolic-array matrix multiplier, covering RTL design, simulation-based verification, selected formal checks, and FPGA implementation using Vivado.

## Features

- Parameterized matrix dimensions and datapath widths.
- Processing elements (PEs) with registered operand propagation and multiply-accumulate datapaths.
- Systolic-array interconnect and matrix-streaming controller.
- Directed testbenches for the streamer, systolic array, and complete matrix multiplier.
- SymbiYosys formal checks for selected PE and controller properties.
- FPGA synthesis and routed implementation targeting an AMD/Xilinx Artix-7 device.

## Architecture

| Module | Responsibility |
|---|---|
| `rtl/systolic_pe.sv` | Processing element with multiply-accumulate datapath |
| `rtl/systolic_array.sv` | Interconnected processing-element array |
| `rtl/matrix_streamer.sv` | Operand-stream generation and computation scheduling |
| `rtl/systolic_matmul.sv` | Integrates the streamer and systolic array |
| `rtl/systolic_matmul_fpga_top.sv` | FPGA-oriented top-level wrapper |

## Verification

The `tb/` directory contains three directed testbenches:

- `tb_matrix_streamer.sv`
- `tb_systolic_array.sv`
- `tb_systolic_matmul.sv`

The reported simulation runs passed these testbenches for the tested configurations. The full matrix-multiplier testbench checks expected matrix results across multiple transactions.

The `formal/` directory contains SymbiYosys harnesses and configuration files for selected processing-element and streamer properties. These are **limited property checks**, not a formal proof of the complete matrix-multiplication system.

## FPGA Implementation Results

**Target device:** AMD/Xilinx Artix-7 `xc7a35tcpg236-1`  
**Clock constraint:** 10 ns (100 MHz)  
**Implementation stage:** Routed

| Metric | Final result |
|---|---:|
| Slice LUTs | 685 |
| Slice registers | 11 |
| DSP48E1 blocks | 4 |
| Block RAM tiles | 0 |
| Worst negative slack (WNS) | +3.165 ns |
| Worst hold slack (WHS) | +0.220 ns |
| Failing setup endpoints | 0 |
| Failing hold endpoints | 0 |

The final timing report shows no failing setup or hold endpoints under the configured constraints. However, it flags missing external I/O delay constraints for nine input ports and two output ports. Therefore, these results should not be interpreted as complete external-interface timing sign-off.

### Implementation reports

The `reports/` directory contains the utilization and timing reports from three implementation stages:

- [Final utilization report](reports/utilization_report_final.txt)
- [Final timing report](reports/timing_report_final.txt)
- [Initial utilization report](reports/utilization_report_initial.txt)
- [Initial timing report](reports/timing_report_initial.txt)
- [Intermediate utilization report](reports/utilization_report_intermediate.txt)
- [Intermediate timing report](reports/timing_report_intermediate.txt)

The reports are retained as stage-specific implementation evidence; differences between stages are not necessarily controlled, apples-to-apples optimization comparisons.

## Repository Structure

```text
.
├── rtl/       # RTL modules
├── tb/        # Simulation testbenches
├── formal/    # Formal harnesses and SymbiYosys configs
├── reports/   # Vivado utilization and timing reports
├── README.md
├── LICENSE
└── .gitignore
```

## Tools

- SystemVerilog
- Icarus Verilog
- Yosys / SymbiYosys
- Boolector
- `sv2v` for converting the streamer RTL for formal-tool compatibility
- AMD/Xilinx Vivado

## Current Scope and Future Work

The project currently demonstrates a modular RTL implementation, directed simulation tests, selected formal properties, and a routed FPGA implementation. Further work includes expanding formal coverage, strengthening cycle-by-cycle streaming assertions, completing external I/O timing constraints, and validating additional parameter configurations.