`timescale 1ns/1ps
`default_nettype none

module dot_product_accel_tb;

    localparam int ELEM_WIDTH   = 8;
    localparam int NUM_ELEMS    = 4;
    localparam int RESULT_WIDTH = 32;
    localparam int VEC_WIDTH    = ELEM_WIDTH * NUM_ELEMS;
    localparam int CLK_PERIOD   = 10;
    localparam int MAX_WAIT_CYCLES = 20;

    logic clk;
    logic rst_n;
    logic start;
    logic [VEC_WIDTH-1:0] vec_a;
    logic [VEC_WIDTH-1:0] vec_b;
    logic [RESULT_WIDTH-1:0] result;
    logic busy;
    logic done;

    int unsigned num_tests;
    int unsigned num_fails;

    dot_product_accel #(
        .ELEM_WIDTH(ELEM_WIDTH),
        .NUM_ELEMS(NUM_ELEMS),
        .RESULT_WIDTH(RESULT_WIDTH)
    ) dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .start  (start),
        .vec_a  (vec_a),
        .vec_b  (vec_b),
        .result (result),
        .busy   (busy),
        .done   (done)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        $dumpfile("sim/waveforms/dot_product_accel_tb.vcd");
        $dumpvars(0, dot_product_accel_tb);
    end

    function automatic logic [31:0] pack4(
        input logic [7:0] x0,
        input logic [7:0] x1,
        input logic [7:0] x2,
        input logic [7:0] x3
    );
        pack4 = {x3, x2, x1, x0};
    endfunction

    function automatic logic [31:0] golden_dot_product(
        input logic [31:0] a,
        input logic [31:0] b
    );
        logic [31:0] ai;
        logic [31:0] bi;
        logic [31:0] sum;

        sum = 32'd0;

        for (int i = 0; i < 4; i++) begin
            ai = (a >> (8*i)) & 32'h0000_00FF;
            bi = (b >> (8*i)) & 32'h0000_00FF;
            sum = sum + (ai * bi);
        end

        golden_dot_product = sum;
    endfunction

    task automatic reset_dut();
        begin
            rst_n = 1'b0;
            start = 1'b0;
            vec_a = '0;
            vec_b = '0;

            repeat (3) @(posedge clk);

            if (result !== 32'd0) begin
                $error("Reset failed: result should be 0");
                num_fails++;
            end

            if (busy !== 1'b0) begin
                $error("Reset failed: busy should be 0");
                num_fails++;
            end

            if (done !== 1'b0) begin
                $error("Reset failed: done should be 0");
                num_fails++;
            end

            rst_n = 1'b1;
            @(negedge clk);
        end
    endtask

    task automatic pulse_start(
        input logic [31:0] a,
        input logic [31:0] b
    );
        begin
            @(negedge clk);
            vec_a  = a;
            vec_b  = b;
            start  = 1'b1;

            @(negedge clk);
            start  = 1'b0;
        end
    endtask

    task automatic wait_for_done(output int cycles_waited);
        begin
            cycles_waited = 0;

            while ((done !== 1'b1) && (cycles_waited <= MAX_WAIT_CYCLES)) begin
                @(negedge clk);
                cycles_waited++;
            end

            if (done !== 1'b1) begin
                $error("Timeout waiting for done");
                num_fails++;
            end
        end
    endtask

    task automatic run_and_check(
        input logic [31:0] a,
        input logic [31:0] b,
        input string test_name
    );
        logic [31:0] expected;
        int cycles;

        begin
            num_tests++;
            expected = golden_dot_product(a, b);

            pulse_start(a, b);

            if (busy !== 1'b1) begin
                $error("[%s] busy should be high after start", test_name);
                num_fails++;
            end

            wait_for_done(cycles);

            if (result !== expected) begin
                $error("[%s] Result mismatch. A=%h B=%h Expected=%0d Got=%0d",
                       test_name, a, b, expected, result);
                num_fails++;
            end else begin
                $display("[PASS] %-30s A=%h B=%h Result=%0d Cycles=%0d",
                         test_name, a, b, result, cycles);
            end

            if (cycles != NUM_ELEMS) begin
                $error("[%s] Expected latency of %0d cycles, got %0d",
                       test_name, NUM_ELEMS, cycles);
                num_fails++;
            end

            if (busy !== 1'b0) begin
                $error("[%s] busy should be low when done is high", test_name);
                num_fails++;
            end

            @(negedge clk);

            if (done !== 1'b0) begin
                $error("[%s] done should only pulse for one cycle", test_name);
                num_fails++;
            end

            repeat (2) @(negedge clk);

            if (result !== expected) begin
                $error("[%s] result should remain stable after done", test_name);
                num_fails++;
            end
        end
    endtask

    task automatic test_start_while_busy();
        logic [31:0] a1;
        logic [31:0] b1;
        logic [31:0] a2;
        logic [31:0] b2;
        logic [31:0] expected1;
        int cycles;

        begin
            num_tests++;

            a1 = pack4(8'd1, 8'd2, 8'd3, 8'd4);
            b1 = pack4(8'd5, 8'd6, 8'd7, 8'd8);

            a2 = pack4(8'd10, 8'd20, 8'd30, 8'd40);
            b2 = pack4(8'd1,  8'd2,  8'd3,  8'd4);

            expected1 = golden_dot_product(a1, b1);

            pulse_start(a1, b1);

            @(negedge clk);

            if (busy !== 1'b1) begin
                $error("[start while busy] DUT should be busy before second start attempt");
                num_fails++;
            end

            vec_a = a2;
            vec_b = b2;
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;

            wait_for_done(cycles);

            if (result !== expected1) begin
                $error("[start while busy] Accelerator should ignore start while busy. Expected=%0d Got=%0d",
                       expected1, result);
                num_fails++;
            end else begin
                $display("[PASS] start while busy ignored correctly");
            end

            @(negedge clk);

            run_and_check(a2, b2, "operation after ignored start");
        end
    endtask

    initial begin
        num_tests = 0;
        num_fails = 0;

        reset_dut();

        run_and_check(
            pack4(8'd12, 8'd0, 8'd0, 8'd0),
            pack4(8'd7,  8'd0, 8'd0, 8'd0),
            "single element"
        );

        run_and_check(
            pack4(8'd1, 8'd2, 8'd3, 8'd4),
            pack4(8'd5, 8'd6, 8'd7, 8'd8),
            "basic dot product"
        );

        run_and_check(
            pack4(8'd0, 8'd0, 8'd0, 8'd0),
            pack4(8'd9, 8'd8, 8'd7, 8'd6),
            "all zero A"
        );

        run_and_check(
            pack4(8'd255, 8'd255, 8'd255, 8'd255),
            pack4(8'd255, 8'd255, 8'd255, 8'd255),
            "max values"
        );

        run_and_check(
            pack4(8'd1, 8'd0, 8'd0, 8'd0),
            pack4(8'd9, 8'd8, 8'd7, 8'd6),
            "one-hot element 0"
        );

        run_and_check(
            pack4(8'd0, 8'd0, 8'd0, 8'd1),
            pack4(8'd9, 8'd8, 8'd7, 8'd6),
            "one-hot element 3"
        );

        test_start_while_busy();

        for (int t = 0; t < 100; t++) begin
            run_and_check($urandom(), $urandom(), $sformatf("random test %0d", t));
        end

        $display("--------------------------------------------------");
        $display("Tests run : %0d", num_tests);
        $display("Failures  : %0d", num_fails);
        $display("--------------------------------------------------");

        if (num_fails == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end

        $finish;
    end

endmodule

`default_nettype wire