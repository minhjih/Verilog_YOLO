module pe27_mac (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [215:0] weights_flat,
    input  wire [215:0] inputs_flat,
    output reg  [23:0]  mac_out,
    output reg          busy,
    output reg          done
);
    localparam ST_IDLE        = 4'd0;
    localparam ST_MUL_START   = 4'd1;
    localparam ST_MUL_WAIT    = 4'd2;
    localparam ST_ADD0_START  = 4'd3;
    localparam ST_ADD0_WAIT   = 4'd4;
    localparam ST_ADD1A_START = 4'd5;
    localparam ST_ADD1A_WAIT  = 4'd6;
    localparam ST_ADD1B_START = 4'd7;
    localparam ST_ADD1B_WAIT  = 4'd8;
    localparam ST_ADD2_START  = 4'd9;
    localparam ST_ADD2_WAIT   = 4'd10;

    reg [3:0]  state;
    reg [4:0]  idx;
    reg [23:0] acc;

    wire [7:0] w_sel;
    wire [7:0] x_sel;

    reg mul_start;
    wire [15:0] mul_product;
    wire mul_done;

    reg add_start;
    reg [7:0] add_a;
    reg [7:0] add_b;
    wire [7:0] add_sum;
    wire add_carry;
    wire add_done;

    reg carry01;
    reg carry12;
    reg [15:0] product_hold;

    assign w_sel = weights_flat[idx*8 +: 8];
    assign x_sel = inputs_flat[idx*8 +: 8];

    multiplier8_seq u_mul (
        .clk(clk),
        .rst_n(rst_n),
        .start(mul_start),
        .a(w_sel),
        .b(x_sel),
        .product(mul_product),
        .busy(),
        .done(mul_done)
    );

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
            state        <= ST_IDLE;
            idx          <= 5'd0;
            acc          <= 24'd0;
            mac_out      <= 24'd0;
            busy         <= 1'b0;
            done         <= 1'b0;
            mul_start    <= 1'b0;
            add_start    <= 1'b0;
            add_a        <= 8'd0;
            add_b        <= 8'd0;
            carry01      <= 1'b0;
            carry12      <= 1'b0;
            product_hold <= 16'd0;
        end else begin
            done      <= 1'b0;
            mul_start <= 1'b0;
            add_start <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (start) begin
                        idx   <= 5'd0;
                        acc   <= 24'd0;
                        busy  <= 1'b1;
                        state <= ST_MUL_START;
                    end
                end

                ST_MUL_START: begin
                    mul_start <= 1'b1;
                    state     <= ST_MUL_WAIT;
                end

                ST_MUL_WAIT: begin
                    if (mul_done) begin
                        product_hold <= mul_product;
                        state        <= ST_ADD0_START;
                    end
                end

                ST_ADD0_START: begin
                    add_a     <= acc[7:0];
                    add_b     <= product_hold[7:0];
                    add_start <= 1'b1;
                    state     <= ST_ADD0_WAIT;
                end

                ST_ADD0_WAIT: begin
                    if (add_done) begin
                        acc[7:0] <= add_sum;
                        carry01  <= add_carry;
                        state    <= ST_ADD1A_START;
                    end
                end

                ST_ADD1A_START: begin
                    add_a     <= acc[15:8];
                    add_b     <= product_hold[15:8];
                    add_start <= 1'b1;
                    state     <= ST_ADD1A_WAIT;
                end

                ST_ADD1A_WAIT: begin
                    if (add_done) begin
                        acc[15:8] <= add_sum;
                        carry12   <= add_carry;
                        if (carry01) begin
                            state <= ST_ADD1B_START;
                        end else begin
                            state <= ST_ADD2_START;
                        end
                    end
                end

                ST_ADD1B_START: begin
                    add_a     <= acc[15:8];
                    add_b     <= 8'b0000_0001;
                    add_start <= 1'b1;
                    state     <= ST_ADD1B_WAIT;
                end

                ST_ADD1B_WAIT: begin
                    if (add_done) begin
                        acc[15:8] <= add_sum;
                        carry12   <= carry12 | add_carry;
                        state     <= ST_ADD2_START;
                    end
                end

                ST_ADD2_START: begin
                    add_a     <= acc[23:16];
                    add_b     <= {7'd0, carry12};
                    add_start <= 1'b1;
                    state     <= ST_ADD2_WAIT;
                end

                ST_ADD2_WAIT: begin
                    if (add_done) begin
                        acc[23:16] <= add_sum;

                        if (idx == 5'd26) begin
                            mac_out <= {add_sum, acc[15:0]};
                            busy    <= 1'b0;
                            done    <= 1'b1;
                            state   <= ST_IDLE;
                        end else begin
                            idx   <= idx + 5'd1;
                            state <= ST_MUL_START;
                        end
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule
