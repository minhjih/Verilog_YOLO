module multiplier8_seq (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] a,
    input  wire [7:0] b,
    output reg [15:0] product,
    output reg        busy,
    output reg        done
);
    localparam ST_IDLE        = 4'd0;
    localparam ST_CHECK_BIT   = 4'd1;
    localparam ST_ADD_LO_S    = 4'd2;
    localparam ST_ADD_LO_W    = 4'd3;
    localparam ST_ADD_HI_S    = 4'd4;
    localparam ST_ADD_HI_W    = 4'd5;
    localparam ST_ADD_CY_S    = 4'd6;
    localparam ST_ADD_CY_W    = 4'd7;
    localparam ST_SHIFT_NEXT  = 4'd8;
    localparam ST_FINISH      = 4'd9;

    reg [3:0] state;
    reg [2:0] bit_idx;
    reg [15:0] multiplicand16;
    reg [7:0]  multiplier;
    reg        carry_lo;

    reg add_start;
    reg [7:0] add_a;
    reg [7:0] add_b;
    wire [7:0] add_sum;
    wire add_carry;
    wire add_done;

    adder8_seq u_add (
        .clk(clk),
        .rst_n(rst_n),
        .start(add_start),
        .a(add_a),
        .b(add_b),
        .sum(add_sum),
        .carry_out(add_carry),
        .busy(),
        .done(add_done)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= ST_IDLE;
            bit_idx       <= 3'd0;
            multiplicand16<= 16'd0;
            multiplier    <= 8'd0;
            product       <= 16'd0;
            busy          <= 1'b0;
            done          <= 1'b0;
            carry_lo      <= 1'b0;
            add_start     <= 1'b0;
            add_a         <= 8'd0;
            add_b         <= 8'd0;
        end else begin
            done      <= 1'b0;
            add_start <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (start) begin
                        multiplicand16 <= {8'd0, a};
                        multiplier     <= b;
                        product        <= 16'd0;
                        bit_idx        <= 3'd0;
                        busy           <= 1'b1;
                        state          <= ST_CHECK_BIT;
                    end
                end

                ST_CHECK_BIT: begin
                    if (multiplier[0]) begin
                        state <= ST_ADD_LO_S;
                    end else begin
                        state <= ST_SHIFT_NEXT;
                    end
                end

                ST_ADD_LO_S: begin
                    add_a     <= product[7:0];
                    add_b     <= multiplicand16[7:0];
                    add_start <= 1'b1;
                    state     <= ST_ADD_LO_W;
                end

                ST_ADD_LO_W: begin
                    if (add_done) begin
                        product[7:0] <= add_sum;
                        carry_lo     <= add_carry;
                        state        <= ST_ADD_HI_S;
                    end
                end

                ST_ADD_HI_S: begin
                    add_a     <= product[15:8];
                    add_b     <= multiplicand16[15:8];
                    add_start <= 1'b1;
                    state     <= ST_ADD_HI_W;
                end

                ST_ADD_HI_W: begin
                    if (add_done) begin
                        product[15:8] <= add_sum;
                        if (carry_lo) begin
                            state <= ST_ADD_CY_S;
                        end else begin
                            state <= ST_SHIFT_NEXT;
                        end
                    end
                end

                ST_ADD_CY_S: begin
                    add_a     <= product[15:8];
                    add_b     <= 8'b0000_0001;
                    add_start <= 1'b1;
                    state     <= ST_ADD_CY_W;
                end

                ST_ADD_CY_W: begin
                    if (add_done) begin
                        product[15:8] <= add_sum;
                        state         <= ST_SHIFT_NEXT;
                    end
                end

                ST_SHIFT_NEXT: begin
                    multiplicand16 <= multiplicand16 << 1;
                    multiplier     <= multiplier >> 1;

                    if (bit_idx == 3'd7) begin
                        state <= ST_FINISH;
                    end else begin
                        bit_idx <= bit_idx + 3'd1;
                        state   <= ST_CHECK_BIT;
                    end
                end

                ST_FINISH: begin
                    busy  <= 1'b0;
                    done  <= 1'b1;
                    state <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule
