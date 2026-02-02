// ReLU activation function module (SystemVerilog)
// y = max(0, x)
module activation_relu #(
    parameter int WIDTH = 16
) (
    input  logic signed [WIDTH-1:0] in_data,
    output logic signed [WIDTH-1:0] out_data
);
    always_comb begin
        if (in_data < 0) begin
            out_data = '0;
        end else begin
            out_data = in_data;
        end
    end
endmodule
