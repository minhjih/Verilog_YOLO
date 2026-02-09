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
    localparam ST_IDLE      = 4'd0;
    localparam ST_MUL_START = 4'd1;
    localparam ST_MUL_WAIT  = 4'd2;
    localparam ST_A1_START  = 4'd3;
    localparam ST_A1_WAIT   = 4'd4;
    localparam ST_A2_START  = 4'd5;
    localparam ST_A2_WAIT   = 4'd6;
    localparam ST_A3_START  = 4'd7;
    localparam ST_A3_WAIT   = 4'd8;
    localparam ST_A4_START  = 4'd9;
    localparam ST_A4_WAIT   = 4'd10;
    localparam ST_A5_START  = 4'd11;
    localparam ST_A5_WAIT   = 4'd12;

    reg [3:0] state;

    reg         mul_start_all;
    wire [431:0] mul_products_flat;
    wire [26:0]  mul_done_vec;

    reg start_a1, start_a2, start_a3, start_a4, start_a5;

    wire [181:0] s1_flat; // 13 * 14-bit
    wire [97:0]  s2_flat; // 7  * 14-bit
    wire [41:0]  s3_flat; // 3  * 14-bit
    wire [27:0]  s4_flat; // 2  * 14-bit
    wire [13:0]  s5;

    wire [12:0] done_a1;
    wire [6:0]  done_a2;
    wire [2:0]  done_a3;
    wire [1:0]  done_a4;
    wire        done_a5;

    // pulse형 done 신호를 latch해서 stage 완료를 안정적으로 감지
    reg [26:0] mul_done_latched;
    reg [12:0] a1_done_latched;
    reg [6:0]  a2_done_latched;
    reg [2:0]  a3_done_latched;
    reg [1:0]  a4_done_latched;
    reg        a5_done_latched;

    wire all_mul_done = &mul_done_latched;
    wire all_done_a1  = &a1_done_latched;
    wire all_done_a2  = &a2_done_latched;
    wire all_done_a3  = &a3_done_latched;
    wire all_done_a4  = &a4_done_latched;

    genvar gi;
    generate
        for (gi = 0; gi < 27; gi = gi + 1) begin : GEN_MUL
            multiplier8_seq u_mul (
                .clk(clk),
                .rst_n(rst_n),
                .start(mul_start_all),
                .a(weights_flat[gi*8 +: 8]),
                .b(inputs_flat[gi*8 +: 8]),
                .product(mul_products_flat[gi*16 +: 16]),
                .busy(),
                .done(mul_done_vec[gi])
            );
        end

        for (gi = 0; gi < 13; gi = gi + 1) begin : GEN_A1
            adder14_cla u_add (
                .clk(clk),
                .rst_n(rst_n),
                .start(start_a1),
                .a({6'd0, mul_products_flat[(2*gi)*16 +: 8]}),
                .b({6'd0, mul_products_flat[(2*gi+1)*16 +: 8]}),
                .sum(s1_flat[gi*14 +: 14]),
                .carry_out(),
                .busy(),
                .done(done_a1[gi])
            );
        end

        for (gi = 0; gi < 7; gi = gi + 1) begin : GEN_A2
            wire [13:0] in_a;
            wire [13:0] in_b;
            assign in_a = (2*gi < 13) ? s1_flat[(2*gi)*14 +: 14] : {6'd0, mul_products_flat[26*16 +: 8]};
            assign in_b = (2*gi+1 < 13) ? s1_flat[(2*gi+1)*14 +: 14] : {6'd0, mul_products_flat[26*16 +: 8]};
            adder14_cla u_add (
                .clk(clk),
                .rst_n(rst_n),
                .start(start_a2),
                .a(in_a),
                .b(in_b),
                .sum(s2_flat[gi*14 +: 14]),
                .carry_out(),
                .busy(),
                .done(done_a2[gi])
            );
        end

        for (gi = 0; gi < 3; gi = gi + 1) begin : GEN_A3
            adder14_cla u_add (
                .clk(clk),
                .rst_n(rst_n),
                .start(start_a3),
                .a(s2_flat[(2*gi)*14 +: 14]),
                .b(s2_flat[(2*gi+1)*14 +: 14]),
                .sum(s3_flat[gi*14 +: 14]),
                .carry_out(),
                .busy(),
                .done(done_a3[gi])
            );
        end

        for (gi = 0; gi < 2; gi = gi + 1) begin : GEN_A4
            wire [13:0] in_a;
            wire [13:0] in_b;
            assign in_a = (gi == 0) ? s3_flat[0*14 +: 14] : s3_flat[2*14 +: 14];
            assign in_b = (gi == 0) ? s3_flat[1*14 +: 14] : s2_flat[6*14 +: 14];
            adder14_cla u_add (
                .clk(clk),
                .rst_n(rst_n),
                .start(start_a4),
                .a(in_a),
                .b(in_b),
                .sum(s4_flat[gi*14 +: 14]),
                .carry_out(),
                .busy(),
                .done(done_a4[gi])
            );
        end

        adder14_cla u_add5 (
            .clk(clk),
            .rst_n(rst_n),
            .start(start_a5),
            .a(s4_flat[0*14 +: 14]),
            .b(s4_flat[1*14 +: 14]),
            .sum(s5),
            .carry_out(),
            .busy(),
            .done(done_a5)
        );
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            mac_out <= 24'd0;
            busy <= 1'b0;
            done <= 1'b0;
            mul_start_all <= 1'b0;
            start_a1 <= 1'b0;
            start_a2 <= 1'b0;
            start_a3 <= 1'b0;
            start_a4 <= 1'b0;
            start_a5 <= 1'b0;
            mul_done_latched <= 27'd0;
            a1_done_latched  <= 13'd0;
            a2_done_latched  <= 7'd0;
            a3_done_latched  <= 3'd0;
            a4_done_latched  <= 2'd0;
            a5_done_latched  <= 1'b0;
        end else begin
            done <= 1'b0;
            mul_start_all <= 1'b0;
            start_a1 <= 1'b0;
            start_a2 <= 1'b0;
            start_a3 <= 1'b0;
            start_a4 <= 1'b0;
            start_a5 <= 1'b0;

            // done latch 업데이트
            mul_done_latched <= mul_done_latched | mul_done_vec;
            a1_done_latched  <= a1_done_latched  | done_a1;
            a2_done_latched  <= a2_done_latched  | done_a2;
            a3_done_latched  <= a3_done_latched  | done_a3;
            a4_done_latched  <= a4_done_latched  | done_a4;
            a5_done_latched  <= a5_done_latched  | done_a5;

            case (state)
                ST_IDLE: begin
                    if (start) begin
                        busy <= 1'b1;
                        mac_out <= 24'd0;
                        mul_done_latched <= 27'd0;
                        a1_done_latched  <= 13'd0;
                        a2_done_latched  <= 7'd0;
                        a3_done_latched  <= 3'd0;
                        a4_done_latched  <= 2'd0;
                        a5_done_latched  <= 1'b0;
                        state <= ST_MUL_START;
                    end
                end

                ST_MUL_START: begin
                    mul_start_all <= 1'b1;
                    mul_done_latched <= 27'd0;
                    state <= ST_MUL_WAIT;
                end

                ST_MUL_WAIT: begin
                    if (all_mul_done) begin
                        a1_done_latched <= 13'd0;
                        state <= ST_A1_START;
                    end
                end

                ST_A1_START: begin
                    start_a1 <= 1'b1;
                    a1_done_latched <= 13'd0;
                    state <= ST_A1_WAIT;
                end

                ST_A1_WAIT: begin
                    if (all_done_a1) begin
                        a2_done_latched <= 7'd0;
                        state <= ST_A2_START;
                    end
                end

                ST_A2_START: begin
                    start_a2 <= 1'b1;
                    a2_done_latched <= 7'd0;
                    state <= ST_A2_WAIT;
                end

                ST_A2_WAIT: begin
                    if (all_done_a2) begin
                        a3_done_latched <= 3'd0;
                        state <= ST_A3_START;
                    end
                end

                ST_A3_START: begin
                    start_a3 <= 1'b1;
                    a3_done_latched <= 3'd0;
                    state <= ST_A3_WAIT;
                end

                ST_A3_WAIT: begin
                    if (all_done_a3) begin
                        a4_done_latched <= 2'd0;
                        state <= ST_A4_START;
                    end
                end

                ST_A4_START: begin
                    start_a4 <= 1'b1;
                    a4_done_latched <= 2'd0;
                    state <= ST_A4_WAIT;
                end

                ST_A4_WAIT: begin
                    if (all_done_a4) begin
                        a5_done_latched <= 1'b0;
                        state <= ST_A5_START;
                    end
                end

                ST_A5_START: begin
                    start_a5 <= 1'b1;
                    a5_done_latched <= 1'b0;
                    state <= ST_A5_WAIT;
                end

                ST_A5_WAIT: begin
                    if (a5_done_latched) begin
                        mac_out <= {10'd0, s5};
                        busy <= 1'b0;
                        done <= 1'b1;
                        state <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule
