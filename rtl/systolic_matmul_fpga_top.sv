module systolic_matmul_fpga_top #(
    parameter int M      = 2,
    parameter int N      = 2,
    parameter int K      = 2,
    parameter int DATA_W = 8,
    parameter int ACC_W  = 20
) (
    input  logic clk,
    input  logic rst,
    input  logic [7:0] seed,
    output logic done,
    output logic pass
);

    logic start;
    logic busy;
    logic launched;
    logic checked;

    logic [DATA_W-1:0] A [M][K];
    logic [DATA_W-1:0] B [K][N];
    logic [ACC_W-1:0] C [M][N];

    logic [ACC_W-1:0] expected [M][N];

    // Generate nonconstant operands from the runtime seed.
    // Keep seed stable until the transaction completes.
    always_comb begin
        for (int i = 0; i < M; i++) begin
            for (int k = 0; k < K; k++) begin
                A[i][k] = DATA_W'(
                    (int'(seed) + 3*i + 2*k + 1) & 8'hFF
                );
            end
        end

        for (int k = 0; k < K; k++) begin
            for (int j = 0; j < N; j++) begin
                B[k][j] = DATA_W'(
                    (int'(seed) + 5*k + 3*j + 2) & 8'hFF
                );
            end
        end
    end

    // Reference matrix multiplication.
    always_comb begin
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
    end

    // Launch one transaction after reset.
    always_ff @(posedge clk) begin
        if (rst) begin
            start    <= 1'b0;
            launched <= 1'b0;
            checked  <= 1'b0;
            pass     <= 1'b0;
        end else begin
            start <= 1'b0;

            if (!launched) begin
                start    <= 1'b1;
                launched <= 1'b1;
            end

            if (done && !checked) begin
                checked <= 1'b1;
                pass    <= 1'b1;

                for (int i = 0; i < M; i++) begin
                    for (int j = 0; j < N; j++) begin
                        if (C[i][j] !== expected[i][j])
                            pass <= 1'b0;
                    end
                end
            end
        end
    end

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

endmodule
