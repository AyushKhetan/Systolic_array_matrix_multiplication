module systolic_matmul #(
    parameter int M      = 2,
    parameter int N      = 2,
    parameter int K      = 2,
    parameter int DATA_W = 8,
    parameter int ACC_W  = 20
) (
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic [DATA_W-1:0] A [M][K],
    input  logic [DATA_W-1:0] B [K][N],

    output logic [ACC_W-1:0] C [M][N],
    output logic busy,
    output logic done
);

// Streamer-to-array connections
logic [DATA_W-1:0] a_stream [M];
logic [DATA_W-1:0] b_stream [N];

logic stream_done;
logic accepted_start;
logic clear_acc;

assign accepted_start = start & !busy;
assign clear_acc = accepted_start;

// Transaction controller.
always_ff @(posedge clk) begin
    if (rst) begin
        busy <= 1'b0;
    end else if (accepted_start) begin
        busy <= 1'b1;
    end else if (stream_done) begin
        busy <= 1'b0;
    end
end

// Generate the staggered operand streams
matrix_streamer #(
    .M(M),
    .N(N),
    .K(K),
    .DATA_W(DATA_W)
) streamer (
    .clk(clk),
    .rst(rst),
    .start(accepted_start),
    .A(A),
    .B(B),
    .a_stream(a_stream),
    .b_stream(b_stream),
    .done(stream_done)
);

// Perform matrix multiplication using the systolic array
systolic_array #(
    .M(M),
    .N(N),
    .DATA_W(DATA_W),
    .ACC_W(ACC_W)
) array (
    .clk(clk),
    .rst(rst),
    .clear_acc(clear_acc),
    .a_input(a_stream),
    .b_input(b_stream),
    .c_output(C)
);


assign done = stream_done;

endmodule