// Max-pooling over a flattened KxK window.
// Input data is provided as a 1-D flattened array of size K*K.
`timescale 1ns/1ps

module max_pool2d #(
    parameter integer K = 2,
    parameter integer WIDTH = 16
) (
    input  [WIDTH*K*K-1:0] in_window_flat,
    output reg signed [WIDTH-1:0] out_max
);
    integer i;
    reg signed [WIDTH-1:0] current_max;
    reg signed [WIDTH-1:0] sample;

    always @* begin
        current_max = $signed(in_window_flat[0 +: WIDTH]);
        for (i = 1; i < K*K; i = i + 1) begin
            sample = $signed(in_window_flat[WIDTH*i +: WIDTH]);
            if (sample > current_max) begin
                current_max = sample;
            end
        end
        out_max = current_max;
    end
endmodule
