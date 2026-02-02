// ReLU activation function module
// y = max(0, x)
`timescale 1ns/1ps

module activation_relu #(
    parameter integer WIDTH = 16
) (
    input  signed [WIDTH-1:0] in_data,
    output reg signed [WIDTH-1:0] out_data
);
    always @* begin
        if (in_data < 0) begin
            out_data = {WIDTH{1'b0}};
        end else begin
            out_data = in_data;
        end
    end
endmodule
