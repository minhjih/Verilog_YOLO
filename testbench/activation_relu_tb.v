`timescale 1ns/1ps

module activation_relu_tb;
    localparam integer WIDTH = 8;

    reg signed [WIDTH-1:0] in_data;
    wire signed [WIDTH-1:0] out_data;

    activation_relu #(
        .WIDTH(WIDTH)
    ) dut (
        .in_data(in_data),
        .out_data(out_data)
    );

    initial begin
        in_data = -8'sd3;
        #1;
        if (out_data !== 0) begin
            $display("FAIL: ReLU(-3) expected 0, got %0d", out_data);
        end else begin
            $display("PASS: ReLU(-3) = 0");
        end

        in_data = 8'sd5;
        #1;
        if (out_data !== 8'sd5) begin
            $display("FAIL: ReLU(5) expected 5, got %0d", out_data);
        end else begin
            $display("PASS: ReLU(5) = 5");
        end

        $finish;
    end
endmodule
