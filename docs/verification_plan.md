# Verification Plan

## Phase 1 Verification

The standalone dot-product accelerator is verified using a SystemVerilog testbench.

## Checked Features

| Test | Purpose |
|---|---|
| Reset test | Confirms outputs initialize correctly |
| Single element test | Checks basic multiplication |
| Basic dot product | Checks normal 4-element operation |
| All-zero input | Checks zero behavior |
| Max-value input | Checks maximum unsigned 8-bit values |
| One-hot input | Checks element ordering |
| Start while busy | Confirms new start is ignored during operation |
| Random tests | Checks many input combinations |
| Done timing | Confirms done pulses for one cycle |
| Result stability | Confirms result remains stable after completion |

## Expected Latency

The Phase 1 accelerator uses one multiply-accumulate operation per cycle.

For a 4-element dot product:

```text
Latency = 4 cycles