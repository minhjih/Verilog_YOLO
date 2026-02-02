`timescale 1ns/1ps

module fcn_matrix_mult_tb;
    localparam integer M = 2;
    localparam integer N = 3;
    localparam integer DATA_WIDTH = 8;
    localparam integer ACC_WIDTH = 16;

    reg [DATA_WIDTH*N-1:0] in_vec_flat;
    reg [DATA_WIDTH*M*N-1:0] weight_flat;
    reg [ACC_WIDTH*M-1:0] bias_flat;
    wire [ACC_WIDTH*M-1:0] out_vec_flat;

    fcn_matrix_mult #(
        .M(M),
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .in_vec_flat(in_vec_flat),
        .weight_flat(weight_flat),
        .bias_flat(bias_flat),
        .out_vec_flat(out_vec_flat)
    );

    initial begin
        in_vec_flat[0 +: DATA_WIDTH] = 8'sd1;
        in_vec_flat[DATA_WIDTH*1 +: DATA_WIDTH] = 8'sd2;
        in_vec_flat[DATA_WIDTH*2 +: DATA_WIDTH] = 8'sd3;

        // m0 weights: [1, 0, -1]
        weight_flat[DATA_WIDTH*0 +: DATA_WIDTH] = 8'sd1;
        weight_flat[DATA_WIDTH*1 +: DATA_WIDTH] = 8'sd0;
        weight_flat[DATA_WIDTH*2 +: DATA_WIDTH] = -8'sd1;
        // m1 weights: [2, 1, 1]
        weight_flat[DATA_WIDTH*3 +: DATA_WIDTH] = 8'sd2;
        weight_flat[DATA_WIDTH*4 +: DATA_WIDTH] = 8'sd1;
        weight_flat[DATA_WIDTH*5 +: DATA_WIDTH] = 8'sd1;

        bias_flat[0 +: ACC_WIDTH] = 16'sd1;
        bias_flat[ACC_WIDTH*1 +: ACC_WIDTH] = -16'sd2;

        #1;
        if ($signed(out_vec_flat[0 +: ACC_WIDTH]) !== -16'sd1) begin
            $display("FAIL: out0 expected -1, got %0d", $signed(out_vec_flat[0 +: ACC_WIDTH]));
        end else begin
            $display("PASS: out0=-1");
        end
        if ($signed(out_vec_flat[ACC_WIDTH*1 +: ACC_WIDTH]) !== 16'sd5) begin
            $display("FAIL: out1 expected 5, got %0d", $signed(out_vec_flat[ACC_WIDTH*1 +: ACC_WIDTH]));
        end else begin
            $display("PASS: out1=5");
        end

        $finish;
    end
endmodule
