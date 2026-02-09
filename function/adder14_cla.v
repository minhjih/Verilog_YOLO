module adder14_cla (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [13:0] a,
    input  wire [13:0] b,
    output reg  [13:0] sum,
    output reg         carry_out,
    output reg         busy,
    output reg         done
);
    localparam ST_IDLE = 1'b0;
    localparam ST_CALC = 1'b1;

    reg        state;
    reg [13:0] a_reg;
    reg [13:0] b_reg;

    wire [13:0] p;
    wire [13:0] g;
    wire [14:0] c;
    wire [13:0] sum_next;

    assign p = a_reg ^ b_reg;
    assign g = a_reg & b_reg;
    assign c[0] = 1'b0;

    genvar i, j;
    generate
        for (i = 1; i <= 14; i = i + 1) begin : GEN_CARRY
            wire [i:1] terms;
            for (j = 0; j < i; j = j + 1) begin : GEN_TERM
                if (j == i-1) begin
                    assign terms[j+1] = g[i-1];
                end else begin
                    assign terms[j+1] = (&p[i-1:j+1]) & g[j];
                end
            end
            assign c[i] = |terms;
        end
    endgenerate

    assign sum_next = p ^ c[13:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= ST_IDLE;
            a_reg     <= 14'd0;
            b_reg     <= 14'd0;
            sum       <= 14'd0;
            carry_out <= 1'b0;
            busy      <= 1'b0;
            done      <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                ST_IDLE: begin
                    if (start) begin
                        a_reg <= a;
                        b_reg <= b;
                        busy  <= 1'b1;
                        state <= ST_CALC;
                    end
                end
                ST_CALC: begin
                    sum       <= sum_next;
                    carry_out <= c[14];
                    busy      <= 1'b0;
                    done      <= 1'b1;
                    state     <= ST_IDLE;
                end
            endcase
        end
    end
endmodule
