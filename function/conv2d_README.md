# conv2d.v

## Purpose
Computes a single output pixel per output channel by convolving a KHxKW patch across input channels.

## Interface (flattened)
- `in_patch_flat[DATA_WIDTH*IN_CH*KH*KW-1:0]`
- `weight_flat[DATA_WIDTH*OUT_CH*IN_CH*KH*KW-1:0]`
- `bias_flat[ACC_WIDTH*OUT_CH-1:0]`
- `out_pix_flat[ACC_WIDTH*OUT_CH-1:0]`

## Timing (predicted)
Combinational datapath. Output updates after propagation delay when any input/weight/bias changes.

### Predicted waveform (example)
Assume `in_patch=[[1,2],[3,4]]`, `weight=[[1,0],[0,1]]`, `bias=0`.

| Time (ns) | out_pix[0] |
|---:|---:|
| 0 | 5 |
| 1 | 5 |
