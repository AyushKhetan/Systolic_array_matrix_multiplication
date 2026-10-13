module matrix_streamer (
	clk,
	rst,
	start,
	A,
	B,
	a_stream,
	b_stream,
	done
);
	reg _sv2v_0;
	parameter signed [31:0] N = 2;
	parameter signed [31:0] M = 2;
	parameter signed [31:0] K = 2;
	parameter signed [31:0] DATA_W = 8;
	input wire clk;
	input wire rst;
	input wire start;
	input wire [((M * K) * DATA_W) - 1:0] A;
	input wire [((K * N) * DATA_W) - 1:0] B;
	output reg [(M * DATA_W) - 1:0] a_stream;
	output reg [(N * DATA_W) - 1:0] b_stream;
	output reg done;
	localparam signed [31:0] TOTAL_CYCLES = ((M + N) + K) - 2;
	localparam signed [31:0] IDLE_COUNT = ((M + N) + K) + 1;
	localparam signed [31:0] COUNT_W = (IDLE_COUNT < 2 ? 1 : $clog2(IDLE_COUNT + 1));
	reg [COUNT_W - 1:0] count;
	reg running;
	always @(posedge clk) begin
		done <= 1'b0;
		if (rst) begin
			count <= IDLE_COUNT;
			running <= 1'b0;
		end
		else if (start && !running) begin
			count <= 1'sb0;
			running <= 1'b1;
		end
		else if (running) begin
			if (count == (TOTAL_CYCLES - 1)) begin
				count <= IDLE_COUNT;
				running <= 1'b0;
				done <= 1'b1;
			end
			else
				count <= count + 1'b1;
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < M; i = i + 1)
				begin
					a_stream[((M - 1) - i) * DATA_W+:DATA_W] = 1'sb0;
					if ((count >= i) && (count < (i + K)))
						a_stream[((M - 1) - i) * DATA_W+:DATA_W] = A[((((M - 1) - i) * K) + ((K - 1) - (count - i))) * DATA_W+:DATA_W];
				end
		end
		begin : sv2v_autoblock_2
			reg signed [31:0] j;
			for (j = 0; j < N; j = j + 1)
				begin
					b_stream[((N - 1) - j) * DATA_W+:DATA_W] = 1'sb0;
					if ((count >= j) && (count < (j + K)))
						b_stream[((N - 1) - j) * DATA_W+:DATA_W] = B[((((K - 1) - (count - j)) * N) + ((N - 1) - j)) * DATA_W+:DATA_W];
				end
		end
	end
	initial _sv2v_0 = 0;
endmodule