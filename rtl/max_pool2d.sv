// Max-pooling over a flattened KxK window.
// Input data is provided as a 1-D array of size K*K.
module max_pool2d #(
    parameter int K = 2,
    parameter int WIDTH = 16
) (
    input  logic signed [WIDTH-1:0] in_window [K*K],
    output logic signed [WIDTH-1:0] out_max
);
    integer i;
    logic signed [WIDTH-1:0] current_max;

    always_comb begin
        current_max = in_window[0];
        for (i = 1; i < K*K; i++) begin
            if (in_window[i] > current_max) begin
                current_max = in_window[i];
            end
        end
        out_max = current_max;
    end
endmodule
