# Cycle Count Results

## Phase 1: Single-MAC Dot Product Accelerator

| Design Version | Description | Dot Product Size | Latency |
|---|---|---:|---:|
| V1 | Single multiply-accumulate datapath | 4 elements | 4 cycles |

## Notes

The first version computes one product per cycle and accumulates the result over four cycles.

Future versions will compare this baseline against:

- parallel multiplier version
- pipelined version
- software-only execution model