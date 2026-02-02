`timescale 1ns/1ps

module conv2d_tb;
    localparam integer IN_CH = 1;
    localparam integer OUT_CH = 1;
    localparam integer KH = 2;
    localparam integer KW = 2;
    localparam integer DATA_WIDTH = 8;
    localparam integer ACC_WIDTH = 16;

    reg [DATA_WIDTH*IN_CH*KH*KW-1:0] in_patch_flat;
    reg [DATA_WIDTH*OUT_CH*IN_CH*KH*KW-1:0] weight_flat;
    reg [ACC_WIDTH*OUT_CH-1:0] bias_flat;
    wire [ACC_WIDTH*OUT_CH-1:0] out_pix_flat;

    conv2d #(
        .IN_CH(IN_CH),
        .OUT_CH(OUT_CH),
        .KH(KH),
        .KW(KW),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .in_patch_flat(in_patch_flat),
        .weight_flat(weight_flat),
        .bias_flat(bias_flat),
        .out_pix_flat(out_pix_flat)
    );

    initial begin
        // in_patch = [[1,2],[3,4]]
        in_patch_flat[0 +: DATA_WIDTH] = 8'sd1;
        in_patch_flat[DATA_WIDTH*1 +: DATA_WIDTH] = 8'sd2;
        in_patch_flat[DATA_WIDTH*2 +: DATA_WIDTH] = 8'sd3;
        in_patch_flat[DATA_WIDTH*3 +: DATA_WIDTH] = 8'sd4;

        // weight = [[1,0],[0,1]]
        weight_flat[0 +: DATA_WIDTH] = 8'sd1;
        weight_flat[DATA_WIDTH*1 +: DATA_WIDTH] = 8'sd0;
        weight_flat[DATA_WIDTH*2 +: DATA_WIDTH] = 8'sd0;
        weight_flat[DATA_WIDTH*3 +: DATA_WIDTH] = 8'sd1;

        bias_flat[0 +: ACC_WIDTH] = 16'sd0;

        #1;
        if ($signed(out_pix_flat[0 +: ACC_WIDTH]) !== 16'sd5) begin
            $display("FAIL: conv expected 5, got %0d", $signed(out_pix_flat[0 +: ACC_WIDTH]));
        end else begin
            $display("PASS: conv=5");
        end

        $finish;
    end
endmodule
