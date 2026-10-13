(* use_dsp = "yes" *)
module systolic_pe #(
    parameter int DATA_W = 8,
    parameter int ACC_W = 2*DATA_W
)(
    input logic                 clk,
    input logic                 rst,
    input logic           clear_acc,

    input logic [DATA_W-1:0]     a_in,
    input logic [DATA_W-1:0]     b_in,

    output logic [DATA_W-1:0]  a_out,
    output logic [DATA_W-1:0]  b_out,

    output logic [ACC_W-1:0]    acc
);

    always_ff @(posedge clk) begin
        if (rst) begin
            a_out <= 0;
            b_out <= 0;
            acc   <= 0;
        end
        else begin
            a_out <= a_in;
            b_out <= b_in;
            if (clear_acc)
                acc <= '0;
            else
                acc   <= acc + a_in * b_in;
        end
    end

endmodule