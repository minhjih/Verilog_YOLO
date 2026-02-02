`timescale 1ns/1ps

module max_pool2d_tb;
    localparam integer K = 2;
    localparam integer WIDTH = 8;

    reg [WIDTH*K*K-1:0] in_window_flat;
    wire signed [WIDTH-1:0] out_max;

    max_pool2d #(
        .K(K),
        .WIDTH(WIDTH)
    ) dut (
        .in_window_flat(in_window_flat),
        .out_max(out_max)
    );

    initial begin
        in_window_flat[0 +: WIDTH] = 8'sd1;
        in_window_flat[WIDTH*1 +: WIDTH] = 8'sd5;
        in_window_flat[WIDTH*2 +: WIDTH] = 8'sd3;
        in_window_flat[WIDTH*3 +: WIDTH] = 8'sd2;
        #1;
        if (out_max !== 8'sd5) begin
            $display("FAIL: max expected 5, got %0d", out_max);
        end else begin
            $display("PASS: max=5");
        end

        in_window_flat[WIDTH*1 +: WIDTH] = 8'sd7;
        #1;
        if (out_max !== 8'sd7) begin
            $display("FAIL: max expected 7, got %0d", out_max);
        end else begin
            $display("PASS: max=7");
        end

        $finish;
    end
endmodule
