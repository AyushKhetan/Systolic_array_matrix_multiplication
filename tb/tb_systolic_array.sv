`timescale 1ns/1ps

module tb_systolic_array;

    localparam int M      = 2;
    localparam int N      = 2;
    localparam int DATA_W = 8;
    localparam int ACC_W  = 2 * DATA_W;

    logic clk;
    logic rst;

    logic [DATA_W-1:0] a_input [M];
    logic [DATA_W-1:0] b_input [N];

    logic [ACC_W-1:0] c_output [M][N];

    // DUT
    systolic_array #(
        .M(M),
        .N(N),
        .DATA_W(DATA_W),
        .ACC_W(ACC_W)
    ) dut (
        .clk       (clk),
        .rst       (rst),
        .a_input   (a_input),
        .b_input   (b_input),
        .c_output  (c_output)
    );

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin

        // Initialize inputs
        rst = 1'b1;

        for (int i = 0; i < M; i++)
            a_input[i] = '0;

        for (int j = 0; j < N; j++)
            b_input[j] = '0;

        // Hold reset across rising edges
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        // Cycle 0: A00 = 1, B00 = 5
        a_input[0] = 1;
        a_input[1] = 0;
        b_input[0] = 5;
        b_input[1] = 0;

        @(negedge clk);

        // Cycle 1: A01 = 2, A10 = 3
        //          B10 = 7, B01 = 6
        a_input[0] = 2;
        a_input[1] = 3;
        b_input[0] = 7;
        b_input[1] = 6;

        @(negedge clk);

        // Cycle 2: A11 = 4, B11 = 8
        a_input[0] = 0;
        a_input[1] = 4;
        b_input[0] = 0;
        b_input[1] = 8;

        @(negedge clk);

        // Stop injecting operands
        for (int i = 0; i < M; i++)
            a_input[i] = '0;

        for (int j = 0; j < N; j++)
            b_input[j] = '0;

        // Allow the final operands to propagate
        repeat (2) @(negedge clk);

        // Check results
        $display("Computed matrix C:");

        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++)
                $write("%0d ", c_output[i][j]);
            $display("");
        end

        if (c_output[0][0] !== 19 ||
            c_output[0][1] !== 22 ||
            c_output[1][0] !== 43 ||
            c_output[1][1] !== 50) begin

            $error("TEST FAILED: Incorrect matrix multiplication");
            $fatal;

        end
        else begin
            $display("TEST PASSED");
        end

        $finish;
    end

endmodule
