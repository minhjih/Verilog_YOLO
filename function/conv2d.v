// Convolution module for a single KHxKW patch across multiple input channels.
// Computes one output pixel for each output channel.
`timescale 1ns/1ps

module conv2d #(
    parameter integer IN_CH = 1,
    parameter integer OUT_CH = 1,
    parameter integer KH = 3,
    parameter integer KW = 3,
    parameter integer DATA_WIDTH = 16,
    parameter integer ACC_WIDTH = 32
) (
    input  [DATA_WIDTH*IN_CH*KH*KW-1:0] in_patch_flat,
    input  [DATA_WIDTH*OUT_CH*IN_CH*KH*KW-1:0] weight_flat,
    input  [ACC_WIDTH*OUT_CH-1:0] bias_flat,
    output reg [ACC_WIDTH*OUT_CH-1:0] out_pix_flat
);
    integer oc;
    integer ic;
    integer ky;
    integer kx;
    reg signed [ACC_WIDTH-1:0] acc;
    reg signed [DATA_WIDTH-1:0] in_sample;
    reg signed [DATA_WIDTH-1:0] w_sample;
    reg signed [ACC_WIDTH-1:0] bias_sample;
    integer in_idx;
    integer w_idx;

    always @* begin
        for (oc = 0; oc < OUT_CH; oc = oc + 1) begin
            bias_sample = $signed(bias_flat[ACC_WIDTH*oc +: ACC_WIDTH]);
            acc = bias_sample;
            for (ic = 0; ic < IN_CH; ic = ic + 1) begin
                for (ky = 0; ky < KH; ky = ky + 1) begin
                    for (kx = 0; kx < KW; kx = kx + 1) begin
                        in_idx = ((ic * KH + ky) * KW + kx);
                        w_idx  = ((((oc * IN_CH + ic) * KH + ky) * KW) + kx);
                        in_sample = $signed(in_patch_flat[DATA_WIDTH*in_idx +: DATA_WIDTH]);
                        w_sample  = $signed(weight_flat[DATA_WIDTH*w_idx +: DATA_WIDTH]);
                        acc = acc + (in_sample * w_sample);
                    end
                end
            end
            out_pix_flat[ACC_WIDTH*oc +: ACC_WIDTH] = acc;
        end
    end
endmodule
