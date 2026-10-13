# Parameterized Systolic-Array Matrix Multiplier

A modular SystemVerilog implementation of a parameterized systolic-array matrix multiplier, with directed RTL verification, formal property checking, and an Artix-7 FPGA implementation.

## Highlights

- Parameterized matrix dimensions (`M`, `N`, `K`) and data/accumulator widths.
- Processing elements (PEs) with registered operand propagation and multiply-accumulate datapaths.
- Systolic-array interconnect and matrix-streaming controller.
- Self-checking directed RTL testbenches for the streamer, array, and complete matrix-multiplication datapath.
- SymbiYosys formal verification of PE arithmetic/control properties and matrix-streamer controller properties.
- Vivado synthesis and routed implementation targeting an Artix-7 device.

## Architecture

| Module | Responsibility |
|---|---|
| `rtl/systolic_pe.sv` | Registered operand propagation and multiply-accumulate operation |
| `rtl/systolic_array.sv` | PE grid and inter-PE connections |
| `rtl/matrix_streamer.sv` | Generates operand streams and controls the computation schedule |
| `rtl/systolic_matmul.sv` | Integrates streaming control and the systolic array |
| `rtl/systolic_matmul_fpga_top.sv` | FPGA-oriented top-level wrapper |

## Verification

The `tb/` directory contains three directed testbenches:

- `tb_matrix_streamer.sv`
- `tb_systolic_array.sv`
- `tb_systolic_matmul.sv`

The recorded regression run passed all three testbenches, including square and rectangular matrix cases and repeated transactions in the full matrix-multiplier testbench.

The `formal/` directory contains SymbiYosys harnesses and configurations for PE arithmetic/control properties and matrix-streamer controller properties. The streamer proof uses an `sv2v`-converted RTL file to support the formal tool flow. Run artifacts are intentionally excluded; the harnesses and configurations are retained so the checks can be rerun.

## FPGA implementation results

**Target device:** AMD/Xilinx Artix-7 `xc7a35tcpg236-1`  
**Clock constraint:** 10 ns (100 MHz)  
**Tool:** Vivado 2026.1  
**Implementation stage:** Routed

| Metric | Result |
|---|---:|
| Slice LUTs | 685 |
| Slice registers | 11 |
| DSP48E1 blocks | 4 |
| Block RAM tiles | 0 |
| Routed worst negative slack (WNS) | +3.165 ns |
| Routed worst hold slack (WHS) | +0.220 ns |
| Setup / hold failing endpoints | 0 / 0 |

Full utilization and timing reports are in `reports/`. The timing report indicates that external I/O timing constraints are not complete; the reported slack figures apply to the constraints present in this implementation run.

## Repository layout

```text
rtl/       Synthesizable SystemVerilog modules
 tb/       Directed RTL testbenches
formal/    Formal harnesses, converted RTL, and SymbiYosys configurations
reports/   Final routed utilization and timing reports
```

## Running simulation

From the repository root, with Icarus Verilog installed:

```bash
mkdir -p build
iverilog -g2012 -s tb_matrix_streamer -o build/tb_streamer.vvp \
  rtl/matrix_streamer.sv tb/tb_matrix_streamer.sv
vvp build/tb_streamer.vvp

iverilog -g2012 -s tb_systolic_array -o build/tb_array.vvp \
  rtl/systolic_pe.sv rtl/systolic_array.sv tb/tb_systolic_array.sv
vvp build/tb_array.vvp

iverilog -g2012 -s tb_systolic_matmul -o build/tb_matmul.vvp \
  rtl/systolic_pe.sv rtl/systolic_array.sv rtl/matrix_streamer.sv \
  rtl/systolic_matmul.sv tb/tb_systolic_matmul.sv
vvp build/tb_matmul.vvp
```

## Running formal checks

The `.sby` configurations use relative paths so the project can be run from a local checkout. Run from the `formal/` directory:

```bash
sby -f pe_formal.sby
sby -f streamer_formal.sby
```

The streamer formal flow uses the committed `matrix_streamer_formal.v` generated with `sv2v` from the SystemVerilog RTL.

## Tools

- SystemVerilog
- Icarus Verilog
- Yosys / SymbiYosys (`sby`)
- Boolector
- `sv2v`
- AMD/Xilinx Vivado

## Project status

This project brings together a parameterized RTL datapath, directed simulation, formal property checking, and FPGA implementation. The included source and reports provide a starting point for extending parameter coverage, strengthening stream-schedule assertions, and exploring additional microarchitectural optimizations.
