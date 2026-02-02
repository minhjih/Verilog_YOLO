# max_pool2d.v

## Purpose
Computes max pooling over a KxK window provided as a flattened input bus.

## Interface (flattened)
- `in_window_flat[WIDTH*K*K-1:0]` packed inputs (index 0 at LSB).
- `out_max[WIDTH-1:0]` signed output.

## Timing (predicted)
Purely combinational. Output updates after propagation delay when any input sample changes.

### Predicted waveform (example)
| Time (ns) | Window values | out_max |
|---:|---|---:|
| 0 | [1,5,3,2] | 5 |
| 1 | [1,5,3,2] | 5 |
| 2 | [1,7,3,2] | 7 |
| 3 | [1,7,3,2] | 7 |
