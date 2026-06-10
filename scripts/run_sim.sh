#!/usr/bin/env bash
set -euo pipefail

mkdir -p sim/build
mkdir -p sim/waveforms
mkdir -p results

SIM_OUT="sim/build/dot_product_accel_tb.vvp"
SIM_LOG="results/dot_product_accel_sim.log"

echo "[INFO] Building dot_product_accel testbench..."
iverilog -g2012 -Wall \
  -o "$SIM_OUT" \
  rtl/dot_product_accel.sv \
  tb/dot_product_accel_tb.sv \
  2>&1 | tee "$SIM_LOG"

echo "[INFO] Running simulation..."
vvp "$SIM_OUT" 2>&1 | tee -a "$SIM_LOG"

echo "[INFO] Simulation log saved to $SIM_LOG"
echo "[INFO] Waveform saved to sim/waveforms/dot_product_accel_tb.vcd"
