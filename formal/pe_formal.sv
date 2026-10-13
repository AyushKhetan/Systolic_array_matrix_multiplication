module pe_formal;

    localparam int DATA_W = 8;
    localparam int ACC_W  = 2*DATA_W;

    (* gclk *) logic clk;
    (* anyseq *) logic rst;
    (* anyseq *) logic clear_acc;
    (* anyseq *) logic [DATA_W-1:0] a_in;
    (* anyseq *) logic [DATA_W-1:0] b_in;

    logic [DATA_W-1:0] a_out;
    logic [DATA_W-1:0] b_out;
    logic [ACC_W-1:0] acc;

    systolic_pe #(
        .DATA_W(DATA_W),
        .ACC_W(ACC_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .clear_acc(clear_acc),
        .a_in(a_in),
        .b_in(b_in),
        .a_out(a_out),
        .b_out(b_out),
        .acc(acc)
    );

    logic past_valid = 1'b0;

    always_ff @(posedge clk) begin
        past_valid <= 1'b1;

        if (past_valid && $past(rst)) begin
            assert(a_out == '0);
            assert(b_out == '0);
            assert(acc   == '0);
        end

        if (past_valid && !$past(rst)) begin
            assert(a_out == $past(a_in));
            assert(b_out == $past(b_in));

            if ($past(clear_acc)) begin
                assert(acc == '0);
            end else begin
                assert(acc ==
                    ($past(acc) +
                     ($past(a_in) * $past(b_in))));
            end
        end
    end

endmodule