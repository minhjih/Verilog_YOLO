# Verilog_YOLO
Verilog of YOLO's basic functions

## Folder layout
- `function/`: core modules (.v) and per-module timing README files.
- `testbench/`: testbenches for each module.

## Modules
- `function/fcn_matrix_mult.v`: Fully-connected (matrix multiplication) block with bias.
- `function/conv2d.v`: Convolution block that computes one output pixel per output channel.
- `function/max_pool2d.v`: KxK max-pooling over a flattened window.
- `function/activation_relu.v`: ReLU activation (max(0, x)).
