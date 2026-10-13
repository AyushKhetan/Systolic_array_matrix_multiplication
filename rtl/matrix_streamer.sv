module matrix_streamer #(
    parameter int N      = 2,
    parameter int M      = 2,
    parameter int K      = 2,
    parameter int DATA_W = 8
) (
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic [DATA_W-1:0] A [M][K],
    input  logic [DATA_W-1:0] B [K][N],

    output logic [DATA_W-1:0] a_stream [M],
    output logic [DATA_W-1:0] b_stream [N],

    output logic done
);

    localparam int TOTAL_CYCLES = M + N + K - 2;
    localparam int IDLE_COUNT   = M + N + K + 1;
    localparam int COUNT_W      =
        (IDLE_COUNT < 2) ? 1 : $clog2(IDLE_COUNT + 1);

    logic [COUNT_W-1:0] count;
    logic running;

    always_ff @(posedge clk) begin
        done <= 1'b0;

        if (rst) begin
            count   <= IDLE_COUNT;
            running <= 1'b0;
        end
        else if (start && !running) begin
            count   <= '0;
            running <= 1'b1;
        end
        else if (running) begin
            if (count == TOTAL_CYCLES - 1) begin
                count   <= IDLE_COUNT;
                running <= 1'b0;
                done    <= 1'b1;
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end

    // No running signal in this combinational datapath.
    // The idle sentinel lies outside all valid operand windows.
    always_comb begin
        for (int i = 0; i < M; i++) begin
            a_stream[i] = '0;

            if ((count >= i) && (count < i + K))
                a_stream[i] = A[i][count-i];
        end

        for (int j = 0; j < N; j++) begin
            b_stream[j] = '0;

            if ((count >= j) && (count < j + K))
                b_stream[j] = B[count-j][j];
        end
    end

endmodule