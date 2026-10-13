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

localparam int TOTAL_CYCLES = M+N+K-2;
localparam int COUNT_W = (TOTAL_CYCLES < 2) ? 1 : $clog2(TOTAL_CYCLES + 1);

logic [COUNT_W-1:0] count;
logic running;

always_ff @(posedge clk) begin
    done <= '0;
    if (rst) begin
        count   <= '0;
        running <= 1'b0;
        done <= '0;
    end

    else if (start & !running) begin
        count   <= '0;
        running <= 1'b1;
    end

    else if (running) begin
        if (count == TOTAL_CYCLES - 1) begin
            running <= 1'b0;
            done <= '1;
        end
        else begin
            count <= count + 1'b1;
        end
    end
end


logic stream_active;

assign stream_active = running;

always_comb begin
    for (int i = 0; i < M; i++) begin
        a_stream[i] = '0;

        if (stream_active && (count >= i) && (count < i + K)) begin
            a_stream[i] = A[i][count-i];
        end
    end

    for (int j = 0; j < N; j++) begin
        b_stream[j] = '0;

        if (stream_active && (count >= j) && (count < j + K)) begin
            b_stream[j] = B[count-j][j];
        end
    end
end


endmodule
