# RISC-V-Hardware-Acceleration-Matrix-Multiply-Dot-Product

## Overview

This project is a SystemVerilog hardware acceleration project focused on building a small coprocessor-style accelerator suitable for a RISC-V-based system.

The current design implements a standalone unsigned dot-product accelerator. The long-term goal is to expand this into a memory-mapped accelerator block that can be controlled by a CPU-style interface and later used as the core building block for matrix multiplication acceleration.

This project is intended to demonstrate:

- RTL design in SystemVerilog
- hardware accelerator microarchitecture
- self-checking verification
- golden-model-based validation
- simulation scripting
- waveform debugging
- hardware/software-style register interface planning
- performance documentation

## Current Status

Phase 1 is complete.

Phase 2 is in progress/completed as a verification and repository-quality checkpoint.

### Completed

- Standalone 4-element unsigned dot-product accelerator
- Sequential single-MAC datapath
- `start` / `busy` / `done` handshake
- Self-checking SystemVerilog testbench
- Python golden model
- Simulation script
- Regression script
- Verification documentation
- Cycle-count documentation

### Planned

- Memory-mapped register wrapper
- Register-level testbench
- CPU-style software driver model
- Matrix multiply flow using repeated dot products
- Performance comparison versus software execution

## Repository Structure

```text
rtl/              SystemVerilog RTL source files
tb/               SystemVerilog testbenches
sim/waveforms/    Generated waveform files
model/            Python golden/reference models
scripts/          Build, simulation, and regression scripts
docs/             Architecture and verification documentation
results/          Markdown summaries and result notes
