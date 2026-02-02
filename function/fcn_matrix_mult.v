// Fully connected (matrix multiplication) module
// out_vec[m] = sum_{n=0..N-1} (in_vec[n] * weight[m][n]) + bias[m]
`timescale 1ns/1ps

module fcn_matrix_mult #(
    parameter integer M = 4,
    parameter integer N = 4,
    parameter integer DATA_WIDTH = 16,
    parameter integer ACC_WIDTH = 32
) (
    input  [DATA_WIDTH*N-1:0] in_vec_flat,
    input  [DATA_WIDTH*M*N-1:0] weight_flat,
    input  [ACC_WIDTH*M-1:0] bias_flat,
    output reg [ACC_WIDTH*M-1:0] out_vec_flat
);
    integer m;
    integer n;
    reg signed [ACC_WIDTH-1:0] acc;
    reg signed [DATA_WIDTH-1:0] in_sample;
    reg signed [DATA_WIDTH-1:0] w_sample;
    reg signed [ACC_WIDTH-1:0] bias_sample;

    always @* begin
        for (m = 0; m < M; m = m + 1) begin
            bias_sample = $signed(bias_flat[ACC_WIDTH*m +: ACC_WIDTH]);
            acc = bias_sample;
            for (n = 0; n < N; n = n + 1) begin
                in_sample = $signed(in_vec_flat[DATA_WIDTH*n +: DATA_WIDTH]);
                w_sample  = $signed(weight_flat[(DATA_WIDTH*(m*N + n)) +: DATA_WIDTH]);
                acc = acc + (in_sample * w_sample);
            end
            out_vec_flat[ACC_WIDTH*m +: ACC_WIDTH] = acc;
        end
    end
endmodule
