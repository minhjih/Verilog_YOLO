# Verilog_YOLO
Verilog of YOLO's basic functions

## RTL modules (SystemVerilog)
- `rtl/fcn_matrix_mult.sv`: Fully-connected (matrix multiplication) block with bias.
- `rtl/conv2d.sv`: Convolution block that computes one output pixel for each output channel.
- `rtl/max_pool2d.sv`: KxK max-pooling over a flattened window.
- `rtl/activation_relu.sv`: ReLU activation (max(0, x)).

All modules are parameterizable for bit widths and sizes, and use SystemVerilog array ports for clarity.
