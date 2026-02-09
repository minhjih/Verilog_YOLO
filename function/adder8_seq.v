module adder8_seq (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] a,
    input  wire [7:0] b,
    output reg  [7:0] sum,
    output reg        carry_out,
    output reg        busy,
    output reg        done
);
    localparam ST_IDLE   = 1'b0;
    localparam ST_CALC   = 1'b1;

    reg        state;
    reg [7:0]  a_reg;
    reg [7:0]  b_reg;

    wire [7:0] p;
    wire [7:0] g;
    wire [8:0] c;
    wire [7:0] sum_next;

    assign p = a_reg ^ b_reg;
    assign g = a_reg & b_reg;

    assign c[0] = 1'b0;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[5] = g[4] | (p[4] & g[3]) | (p[4] & p[3] & g[2]) | (p[4] & p[3] & p[2] & g[1]) | (p[4] & p[3] & p[2] & p[1] & g[0]) | (p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[6] = g[5] | (p[5] & g[4]) | (p[5] & p[4] & g[3]) | (p[5] & p[4] & p[3] & g[2]) | (p[5] & p[4] & p[3] & p[2] & g[1]) | (p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) | (p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[7] = g[6] | (p[6] & g[5]) | (p[6] & p[5] & g[4]) | (p[6] & p[5] & p[4] & g[3]) | (p[6] & p[5] & p[4] & p[3] & g[2]) | (p[6] & p[5] & p[4] & p[3] & p[2] & g[1]) | (p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) | (p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[8] = g[7] | (p[7] & g[6]) | (p[7] & p[6] & g[5]) | (p[7] & p[6] & p[5] & g[4]) | (p[7] & p[6] & p[5] & p[4] & g[3]) | (p[7] & p[6] & p[5] & p[4] & p[3] & g[2]) | (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & g[1]) | (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) | (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);

    assign sum_next[0] = p[0] ^ c[0];
    assign sum_next[1] = p[1] ^ c[1];
    assign sum_next[2] = p[2] ^ c[2];
    assign sum_next[3] = p[3] ^ c[3];
    assign sum_next[4] = p[4] ^ c[4];
    assign sum_next[5] = p[5] ^ c[5];
    assign sum_next[6] = p[6] ^ c[6];
    assign sum_next[7] = p[7] ^ c[7];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= ST_IDLE;
            a_reg     <= 8'd0;
            b_reg     <= 8'd0;
            sum       <= 8'd0;
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
                    carry_out <= c[8];
                    busy      <= 1'b0;
                    done      <= 1'b1;
                    state     <= ST_IDLE;
                end

                default: begin
                    state <= ST_IDLE;
                end
            endcase
        end
    end
endmodule
