`timescale 1ns/1ps

module tb_systolic_matmul;

    localparam int M = 2;
    localparam int N = 3;
    localparam int K = 4;
    localparam int DATA_W = 8;
    localparam int ACC_W = 20;
    localparam int TIMEOUT_CYCLES = M + N + K + 10;

    logic clk = 1'b0;
    logic rst = 1'b1;
    logic start = 1'b0;

    logic [DATA_W-1:0] A [M][K];
    logic [DATA_W-1:0] B [K][N];
    logic [ACC_W-1:0] C [M][N];

    logic busy, done;

    logic [ACC_W-1:0] expected [M][N];

    int errors;
    int transaction_count;
    bit completed;

    systolic_matmul #(
        .M(M),
        .N(N),
        .K(K),
        .DATA_W(DATA_W),
        .ACC_W(ACC_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .C(C),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    task automatic calculate_reference;
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                expected[i][j] = '0;
                for (int k = 0; k < K; k++) begin
                    expected[i][j] =
                        expected[i][j] +
                        (ACC_W'(A[i][k]) * ACC_W'(B[k][j]));
                end
            end
        end
    endtask

    task automatic check_result(input int txn);
        errors = 0;

        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                if (C[i][j] !== expected[i][j]) begin
                    $error(
                        "Txn %0d: C[%0d][%0d] expected %0d, got %0d",
                        txn, i, j, expected[i][j], C[i][j]
                    );
                    errors++;
                end
            end
        end

        if (errors != 0)
            $fatal(1, "Transaction %0d failed (%0d mismatches)",
                   txn, errors);

        $display("PASS: Transaction %0d result matches reference.", txn);
    endtask

    task automatic launch_and_check(input int txn);
        begin
            calculate_reference();

            // Request a transaction with a one-cycle start pulse.
            @(negedge clk);
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;

            // Wait for busy to assert.
            if (busy !== 1'b1)
                $fatal(1, "Txn %0d: busy did not assert.", txn);

            // Wait for done, with a bounded timeout.
            completed = 0;

            for (int cycle = 0;
                 cycle < TIMEOUT_CYCLES;
                 cycle++) begin

                @(posedge clk);
                #1;

                if (done === 1'b1) begin
                    completed = 1;
                    break;
                end
            end

            if (!completed)
                $fatal(1, "Txn %0d timed out waiting for done.", txn);

            check_result(txn);

            // Allow the controller to return to idle.
            @(posedge clk);
            #1;

            if (busy !== 1'b0)
                $fatal(1, "Txn %0d: busy did not deassert.", txn);

            if (done !== 1'b0)
                $fatal(1, "Txn %0d: done was not a one-cycle pulse.", txn);
        end
    endtask

    initial begin
        transaction_count = 0;

        // Hold reset initially.
        repeat (2) @(negedge clk);
        rst = 1'b0;

        // --------------------------------------------------
        // Transaction 1: distinct, nontrivial values
        // --------------------------------------------------
        A[0][0]=1; A[0][1]=2; A[0][2]=3; A[0][3]=4;
        A[1][0]=5; A[1][1]=6; A[1][2]=7; A[1][3]=8;

        B[0][0]=11; B[0][1]=12; B[0][2]=13;
        B[1][0]=21; B[1][1]=22; B[1][2]=23;
        B[2][0]=31; B[2][1]=32; B[2][2]=33;
        B[3][0]=41; B[3][1]=42; B[3][2]=43;

        launch_and_check(1);

        // --------------------------------------------------
        // Transaction 2: all ones
        // --------------------------------------------------
        for (int i = 0; i < M; i++)
            for (int k = 0; k < K; k++)
                A[i][k] = 1;

        for (int k = 0; k < K; k++)
            for (int j = 0; j < N; j++)
                B[k][j] = 1;

        launch_and_check(2);

        // --------------------------------------------------
        // Transaction 3: zero A, nonzero B
        // Detects stale accumulator contents.
        // --------------------------------------------------
        for (int i = 0; i < M; i++)
            for (int k = 0; k < K; k++)
                A[i][k] = 0;

        for (int k = 0; k < K; k++)
            for (int j = 0; j < N; j++)
                B[k][j] = 7;

        launch_and_check(3);

        $display("\nPASS: All three transactions completed without reset.");
        $finish;
    end

    // Ensure a start pulse while busy is ignored.
    initial begin
        wait (busy === 1'b1);
        @(negedge clk);

        start = 1'b1;
        @(negedge clk);
        start = 1'b0;

        // This is a smoke check; result and completion checks above
        // verify the transactions themselves.
        $display("Injected start pulse while busy.");
    end

endmodule
