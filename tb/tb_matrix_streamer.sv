`timescale 1ns/1ps

module tb_matrix_streamer;

    localparam int M      = 2;
    localparam int N      = 3;
    localparam int K      = 4;
    localparam int DATA_W = 8;
    localparam int TOTAL_CYCLES = M + N + K - 2;

    logic clk;
    logic rst;
    logic start;

    logic [DATA_W-1:0] A [M][K];
    logic [DATA_W-1:0] B [K][N];

    logic [DATA_W-1:0] a_stream [M];
    logic [DATA_W-1:0] b_stream [N];

    logic done;

    matrix_streamer #(
        .M(M),
        .N(N),
        .K(K),
        .DATA_W(DATA_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .a_stream(a_stream),
        .b_stream(b_stream),
        .done(done)
    );

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst   = 1'b1;
        start = 1'b0;

        // A is 2x4
        A[0][0] = 1; A[0][1] = 2;
        A[0][2] = 3; A[0][3] = 4;

        A[1][0] = 5; A[1][1] = 6;
        A[1][2] = 7; A[1][3] = 8;

        // B is 4x3
        B[0][0] = 11; B[0][1] = 12; B[0][2] = 13;
        B[1][0] = 21; B[1][1] = 22; B[1][2] = 23;
        B[2][0] = 31; B[2][1] = 32; B[2][2] = 33;
        B[3][0] = 41; B[3][1] = 42; B[3][2] = 43;

        // Apply reset
        repeat (2) @(negedge clk);
        rst = 1'b0;

        // Start with a one-cycle pulse
        @(negedge clk);
        start = 1'b1;
        @(negedge clk);
        start = 1'b0;
        #1;
        $display("\nCycle | a_stream[0] a_stream[1] | b_stream[0] b_stream[1] b_stream[2] | done");
        $display("------+-------------------------+-------------------------------------+-----");
        $display("  %0d   |      %0d          %0d     |      %0d          %0d          %0d     |  %0b",
                    0,
                    a_stream[0], a_stream[1],
                    b_stream[0], b_stream[1], b_stream[2],
                    done);

        

        // Observe each cycle after signals have settled.
        // The first active stream cycle is count=0.
        for (int cycle = 1; cycle < TOTAL_CYCLES; cycle++) begin
            @(negedge clk);
            #1;
            $display("  %0d   |      %0d          %0d     |      %0d          %0d          %0d     |  %0b",
                     cycle,
                     a_stream[0], a_stream[1],
                     b_stream[0], b_stream[1], b_stream[2],
                     done);
        end

        // The final stream values have been sampled by the DUT
        // on the final active rising edge. Check completion.
        @(negedge clk);
        #1;
        if (done !== 1'b1) begin
            $error("FAIL: done was not asserted when expected.");
            $fatal;
        end

        $display("PASS: done asserted.");
        $finish;
    end

endmodule