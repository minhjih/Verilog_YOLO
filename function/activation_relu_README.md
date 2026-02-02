# activation_relu.v

## Purpose
Implements ReLU activation: `out = max(0, in)`.

## Interface (flattened)
- `in_data[WIDTH-1:0]` signed input.
- `out_data[WIDTH-1:0]` signed output.

## Timing (predicted)
This is purely combinational logic. Output updates after combinational propagation delay (modeled as the `#1` delay in the testbench).

### Predicted waveform (example)
| Time (ns) | in_data | out_data |
|---:|---:|---:|
| 0 | -3 | 0 |
| 1 | -3 | 0 |
| 2 | 5 | 5 |
| 3 | 5 | 5 |
