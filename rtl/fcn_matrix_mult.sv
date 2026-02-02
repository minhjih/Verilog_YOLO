// Fully connected (matrix multiplication) module
// out_vec[m] = sum_{n=0..N-1} (in_vec[n] * weight[m][n]) + bias[m]
module fcn_matrix_mult #(
    parameter int M = 4,
    parameter int N = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH = 32
) (
    input  logic signed [DATA_WIDTH-1:0] in_vec   [N],
    input  logic signed [DATA_WIDTH-1:0] weight   [M][N],
    input  logic signed [ACC_WIDTH-1:0]  bias     [M],
    output logic signed [ACC_WIDTH-1:0]  out_vec  [M]
);
    integer m;
    integer n;
    logic signed [ACC_WIDTH-1:0] acc;

    always_comb begin
        for (m = 0; m < M; m++) begin
            acc = bias[m];
            for (n = 0; n < N; n++) begin
                acc = acc + $signed(in_vec[n]) * $signed(weight[m][n]);
            end
            out_vec[m] = acc;
        end
    end
endmodule
