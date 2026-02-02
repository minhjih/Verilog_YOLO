# fcn_matrix_mult.v

## Purpose
Computes a fully-connected layer: `out_vec[m] = sum(in_vec[n] * weight[m][n]) + bias[m]`.

## Interface (flattened)
- `in_vec_flat[DATA_WIDTH*N-1:0]`
- `weight_flat[DATA_WIDTH*M*N-1:0]`
- `bias_flat[ACC_WIDTH*M-1:0]`
- `out_vec_flat[ACC_WIDTH*M-1:0]`

## Timing (predicted)
Combinational datapath. Output updates after propagation delay when any input/weight/bias changes.

### Predicted waveform (example)
Assume `in_vec = [1,2,3]`, `w0=[1,0,-1]`, `w1=[2,1,1]`, `bias=[1,-2]`.

| Time (ns) | out_vec[0] | out_vec[1] |
|---:|---:|---:|
| 0 | -1 | 5 |
| 1 | -1 | 5 |
