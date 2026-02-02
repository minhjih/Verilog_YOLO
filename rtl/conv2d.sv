// Convolution module for a single KxK patch across multiple input channels.
// This computes one output pixel for each output channel.
module conv2d #(
    parameter int IN_CH = 1,
    parameter int OUT_CH = 1,
    parameter int KH = 3,
    parameter int KW = 3,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH = 32
) (
    input  logic signed [DATA_WIDTH-1:0] in_patch [IN_CH][KH][KW],
    input  logic signed [DATA_WIDTH-1:0] weight   [OUT_CH][IN_CH][KH][KW],
    input  logic signed [ACC_WIDTH-1:0]  bias     [OUT_CH],
    output logic signed [ACC_WIDTH-1:0]  out_pix  [OUT_CH]
);
    integer oc;
    integer ic;
    integer ky;
    integer kx;
    logic signed [ACC_WIDTH-1:0] acc;

    always_comb begin
        for (oc = 0; oc < OUT_CH; oc++) begin
            acc = bias[oc];
            for (ic = 0; ic < IN_CH; ic++) begin
                for (ky = 0; ky < KH; ky++) begin
                    for (kx = 0; kx < KW; kx++) begin
                        acc = acc + $signed(in_patch[ic][ky][kx]) *
                                    $signed(weight[oc][ic][ky][kx]);
                    end
                end
            end
            out_pix[oc] = acc;
        end
    end
endmodule
