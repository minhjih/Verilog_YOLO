// ReLU activation function module
// y = max(0, x)
`timescale 1ns/1ps

module activation_relu #(
    parameter integer WIDTH = 16
) (
    input  signed [WIDTH-1:0] in_data,
    output wire signed [WIDTH-1:0] out_data
);
    
    assign out_data = in_data[WIDTH-1] ? {WIDTH{1'b0}} : in_data;

endmodule
