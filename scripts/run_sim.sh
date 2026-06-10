#!/bin/bash

set -e

mkdir -p sim/waveforms

echo "Compiling dot_product_accel testbench..."

iverilog -g2012 \
  -o sim/dot_product_accel_tb.vvp \
  rtl/dot_product_accel.sv \
  tb/dot_product_accel_tb.sv

echo "Running simulation..."

vvp sim/dot_product_accel_tb.vvp

echo "Simulation complete."
echo "Waveform saved to sim/waveforms/dot_product_accel_tb.vcd"