# Parameterized Systolic-Array Matrix Multiplier

A modular SystemVerilog implementation of a parameterized systolic-array matrix multiplier, developed to explore RTL microarchitecture, functional verification, formal property checking, and FPGA implementation.

## Highlights

- Parameterized matrix dimensions (`M`, `N`, `K`) and datapath widths.
- Processing elements (PEs) with registered operand propagation and multiply-accumulate datapaths.
- Systolic-array interconnect and matrix-streaming controller.
- Directed testbenches for the streamer, systolic array, and complete matrix-multiplication datapath.
- SymbiYosys formal checks for selected PE arithmetic/control and streamer controller properties.
- Vivado synthesis, implementation, resource utilization, and timing analysis targeting an Artix-7 FPGA.

## Architecture

| Module | Responsibility |
|---|---|
| `rtl/systolic_pe.sv` | Processing element with registered operand propagation and multiply-accumulate datapath |
| `rtl/systolic_array.sv` | PE grid and inter-PE connections |
| `rtl/matrix_streamer.sv` | Generates operand streams and controls the computation schedule |
| `rtl/systolic_matmul.sv` | Integrates streaming control and the systolic array |
| `rtl/systolic_matmul_fpga_top.sv` | FPGA-oriented top-level wrapper |

The design separates the processing elements, array interconnect, operand-stream generation, and transaction-level control into modular RTL components.

**Source selection:** `rtl/matrix_streamer.sv` is the intended streamer for the commands documented below. `rtl/matrix_streamer1.sv` is an alternate implementation that declares the same module name; do not compile both files together.

## Verification

### RTL simulation

The `tb/` directory contains three directed testbenches:

- `tb_matrix_streamer.sv`
- `tb_systolic_array.sv`
- `tb_systolic_matmul.sv`

The testbenches exercise the streamer, array, and integrated matrix-multiplication datapath. The full-system testbench checks expected matrix results across multiple transactions and exercises controller behavior.

The reported regression run passed all three testbenches for the tested configurations.

#### Run the simulations

Requirements: Icarus Verilog with SystemVerilog support.

Run the following commands from the repository root.

**1. Matrix streamer**

```bash
iverilog -g2012 -s tb_matrix_streamer \
  -o /tmp/tb_streamer \
  rtl/matrix_streamer.sv \
  tb/tb_matrix_streamer.sv

vvp /tmp/tb_streamer
```

**2. Systolic array**

```bash
iverilog -g2012 -s tb_systolic_array \
  -o /tmp/tb_array \
  rtl/systolic_pe.sv \
  rtl/systolic_array.sv \
  tb/tb_systolic_array.sv

vvp /tmp/tb_array
```

**3. Complete matrix multiplier**

```bash
iverilog -g2012 -s tb_systolic_matmul \
  -o /tmp/tb_matmul \
  rtl/systolic_pe.sv \
  rtl/systolic_array.sv \
  rtl/matrix_streamer.sv \
  rtl/systolic_matmul.sv \
  tb/tb_systolic_matmul.sv

vvp /tmp/tb_matmul
```

Each command compiles a single testbench with its required RTL dependencies. Temporary simulation executables are written to `/tmp`.

### Formal verification

The `formal/` directory contains SymbiYosys configurations and formal harnesses for selected properties.

- **Processing element:** Selected arithmetic and control properties, including registered operand propagation, reset, accumulator clearing, and accumulator recurrence.
- **Matrix streamer:** Selected controller properties concerning reset behavior and `done` pulse behavior.

The streamer proof uses `matrix_streamer_formal.v`, a converted Verilog representation of the streamer RTL for compatibility with the formal toolchain.

#### Run the formal checks

Requirements: SymbiYosys, Yosys, and Boolector.

Run the checks from the `formal/` directory:

```bash
cd formal

sby -f pe_formal.sby
sby -f streamer_formal.sby

cd ..
```

Both configurations have completed successfully in the development environment. These checks cover selected properties; they do not constitute a formal proof of the complete matrix-multiplication system or all possible parameter configurations.

## FPGA Implementation Results

**Target device:** AMD/Xilinx Artix-7 `xc7a35tcpg236-1`  
**Clock constraint:** 10 ns (100 MHz)  
**Implementation stage:** Routed

| Resource / timing metric | Result |
|---|---:|
| Slice LUTs | 685 |
| Slice registers | 11 |
| DSP48E1 blocks | 4 |
| Block RAM tiles | 0 |
| Worst negative slack (WNS) | +3.165 ns |
| Worst hold slack (WHS) | +0.220 ns |
| Failing setup endpoints | 0 |
| Failing hold endpoints | 0 |

The final routed timing report shows zero failing setup and hold endpoints under the configured constraints. The report also identifies missing external input/output delay constraints for nine input ports and two output ports; therefore, these results should not be interpreted as complete external-interface timing sign-off.

### Implementation reports

The `reports/` directory contains the actual Vivado utilization and timing reports from three implementation stages.

| Stage | Utilization report | Timing report |
|---|---|---|
| Initial | [Utilization](reports/utilization_report_initial.txt) | [Timing](reports/timing_report_initial.txt) |
| Intermediate | [Utilization](reports/utilization_report_intermediate.txt) | [Timing](reports/timing_report_intermediate.txt) |
| Final | [Utilization](reports/utilization_report_final.txt) | [Timing](reports/timing_report_final.txt) |

The reports provide implementation evidence at each recorded stage. Results from different stages should not automatically be interpreted as a controlled, apples-to-apples optimization comparison.

## Repository Structure

```text
.
├── rtl/
│   ├── files.f
│   ├── systolic_pe.sv
│   ├── systolic_array.sv
│   ├── matrix_streamer.sv
│   ├── matrix_streamer1.sv
│   ├── systolic_matmul.sv
│   └── systolic_matmul_fpga_top.sv
├── tb/
│   ├── tb_matrix_streamer.sv
│   ├── tb_systolic_array.sv
│   └── tb_systolic_matmul.sv
├── formal/
│   ├── pe_formal.sv
│   ├── pe_formal.sby
│   ├── streamer_formal.sv
│   ├── streamer_formal.sby
│   └── matrix_streamer_formal.v
├── reports/
│   ├── timing_report_initial.txt
│   ├── timing_report_intermediate.txt
│   ├── timing_report_final.txt
│   ├── utilization_report_initial.txt
│   ├── utilization_report_intermediate.txt
│   └── utilization_report_final.txt
├── README.md
├── LICENSE
└── .gitignore
```

## Tools

- SystemVerilog
- Icarus Verilog
- Yosys / SymbiYosys
- Boolector SMT solver
- `sv2v` for formal-tool compatibility
- AMD/Xilinx Vivado

## Future Work

- Expand formal coverage of the streaming schedule and integrated datapath.
- Strengthen cycle-by-cycle assertions for operand-stream generation.
- Test accumulator clearing and additional parameter configurations.
- Complete external I/O timing constraints and perform further implementation analysis.