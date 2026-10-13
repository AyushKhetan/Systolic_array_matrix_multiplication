
module streamer_formal;

    localparam integer M = 2;
    localparam integer N = 2;
    localparam integer K = 2;
    localparam integer DATA_W = 8;

    (* gclk *) logic clk;
    (* anyseq *) logic rst;
    (* anyseq *) logic start;

    (* anyseq *) logic [M*K*DATA_W-1:0] A;
    (* anyseq *) logic [K*N*DATA_W-1:0] B;

    wire [M*DATA_W-1:0] a_stream;
    wire [N*DATA_W-1:0] b_stream;
    wire done;

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

    logic past_valid = 1'b0;

    always @(posedge clk) begin
        if (!past_valid)
            assume(rst);

        past_valid <= 1'b1;

        // A reset on the preceding cycle must clear done.
        if (past_valid && $past(rst))
            assert(!done);

        // done must not remain high for consecutive cycles.
        if (past_valid && $past(done))
            assert(!done);
    end

endmodule
