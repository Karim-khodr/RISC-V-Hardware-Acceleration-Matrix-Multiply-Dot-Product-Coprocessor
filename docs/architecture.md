# Architecture

## Phase 1: Standalone Dot Product Accelerator

The first accelerator version implements a 4-element unsigned dot product.

Each input vector is packed into a 32-bit word:

| Bits | Element |
|---|---|
| [7:0] | element 0 |
| [15:8] | element 1 |
| [23:16] | element 2 |
| [31:24] | element 3 |

The accelerator computes:

```text
result = a0*b0 + a1*b1 + a2*b2 + a3*b3