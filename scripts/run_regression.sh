#!/usr/bin/env bash
set -euo pipefail

mkdir -p results

REGRESSION_LOG="results/regression_summary.log"
SIM_CONSOLE_LOG="results/regression_sim_console.log"
GOLDEN_LOG="results/golden_model.log"

echo "========================================" | tee "$REGRESSION_LOG"
echo "Project Regression Run" | tee -a "$REGRESSION_LOG"
echo "========================================" | tee -a "$REGRESSION_LOG"
echo "Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")" | tee -a "$REGRESSION_LOG"
echo "" | tee -a "$REGRESSION_LOG"

set +e

echo "[STEP] Running SystemVerilog simulation..." | tee -a "$REGRESSION_LOG"
./scripts/run_sim.sh 2>&1 | tee "$SIM_CONSOLE_LOG"
SIM_STATUS=${PIPESTATUS[0]}

echo "" | tee -a "$REGRESSION_LOG"
echo "[STEP] Running Python golden model..." | tee -a "$REGRESSION_LOG"
python3 model/golden_model.py 2>&1 | tee "$GOLDEN_LOG"
GOLDEN_STATUS=${PIPESTATUS[0]}

set -e

echo "" | tee -a "$REGRESSION_LOG"
echo "========================================" | tee -a "$REGRESSION_LOG"
echo "Regression Summary" | tee -a "$REGRESSION_LOG"
echo "========================================" | tee -a "$REGRESSION_LOG"
echo "SystemVerilog simulation status : $SIM_STATUS" | tee -a "$REGRESSION_LOG"
echo "Python golden model status      : $GOLDEN_STATUS" | tee -a "$REGRESSION_LOG"

if [[ "$SIM_STATUS" -eq 0 && "$GOLDEN_STATUS" -eq 0 ]]; then
  echo "Regression result               : PASS" | tee -a "$REGRESSION_LOG"
  exit 0
else
  echo "Regression result               : FAIL" | tee -a "$REGRESSION_LOG"
  exit 1
fi
EOF
