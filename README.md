# Systolic Array Accelerator (SystemVerilog)

8×8 weight-stationary systolic array accelerator with pipelined 8-bit signed MAC PEs.
Includes RTL, basic testbench, and SoC-style integration hooks.

## Features
- 8×8 PE array, weight-stationary dataflow
- Pipelined signed 8-bit MAC
- Controller FSM + buffer/handshake logic
- (Optional) AHB subordinate wrapper for SoC integration

## Repo Structure
- `rtl/` : synthesizable SystemVerilog RTL
- `tb/`  : testbench and test vectors
- `docs/`: block diagram / pipeline notes

## Quick Start (Simulation)
Example (Questa / ModelSim):
```bash
vlog rtl/*.sv tb/*.sv
vsim tb_top
run -all
