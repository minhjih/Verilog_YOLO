`timescale 1ns/1ps

module pe27_mac_tb;
    reg         clk;
    reg         rst_n;
    reg         start;
    reg [215:0] weights_flat;
    reg [215:0] inputs_flat;

    wire [23:0] mac_out;
    wire        busy;
    wire        done;

    integer i;
    integer cycle_cnt;

    reg [7:0] expected8;

    pe27_mac dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .weights_flat(weights_flat),
        .inputs_flat(inputs_flat),
        .mac_out(mac_out),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    task run_case;
        input [8*64-1:0] case_name;
        input [7:0] exp_val;
        begin
            expected8 = exp_val;

            // start pulse
            @(negedge clk);
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;

            // wait done with timeout
            cycle_cnt = 0;
            while (!done && cycle_cnt < 20000) begin
                @(negedge clk);
                cycle_cnt = cycle_cnt + 1;
            end

            if (cycle_cnt >= 20000) begin
                $display("[FAIL] %0s : timeout", case_name);
                $finish;
            end

            // 병렬 multiplier + adder tree 구조에서 과도한 지연 방지
            if (cycle_cnt > 300) begin
                $display("[FAIL] %0s : too many cycles (%0d)", case_name, cycle_cnt);
                $finish;
            end

            // overflow 없음 가정: 결과는 8bit, 상위 비트는 0이어야 함
            if (mac_out[7:0] !== expected8 || mac_out[23:14] !== 10'd0) begin
                $display("[FAIL] %0s : mac_out=%0d (0x%h), expected8=%0d", case_name, mac_out, mac_out, expected8);
                $finish;
            end

            $display("[PASS] %0s : mac_out=%0d (cycles=%0d)", case_name, mac_out[7:0], cycle_cnt);
        end
    endtask

    initial begin
        clk         = 1'b0;
        rst_n       = 1'b0;
        start       = 1'b0;
        weights_flat= 216'd0;
        inputs_flat = 216'd0;

        repeat (4) @(negedge clk);
        rst_n = 1'b1;

        // CASE 1: 모든 wi=1, xi=1 -> sum = 27
        for (i = 0; i < 27; i = i + 1) begin
            weights_flat[i*8 +: 8] = 8'd1;
            inputs_flat[i*8 +: 8]  = 8'd1;
        end
        run_case("all ones", 8'd27);

        // CASE 2: 앞 9개만 wi=2, xi=3 -> sum = 9 * 6 = 54, 나머지는 0
        weights_flat = 216'd0;
        inputs_flat  = 216'd0;
        for (i = 0; i < 9; i = i + 1) begin
            weights_flat[i*8 +: 8] = 8'd2;
            inputs_flat[i*8 +: 8]  = 8'd3;
        end
        run_case("first 9 terms", 8'd54);

        // CASE 3: 27개 모두 wi=2, xi=2 -> sum = 27 * 4 = 108
        weights_flat = 216'd0;
        inputs_flat  = 216'd0;
        for (i = 0; i < 27; i = i + 1) begin
            weights_flat[i*8 +: 8] = 8'd2;
            inputs_flat[i*8 +: 8]  = 8'd2;
        end
        run_case("all twos", 8'd108);

        $display("All pe27_mac tests passed.");
        $finish;
    end
endmodule
