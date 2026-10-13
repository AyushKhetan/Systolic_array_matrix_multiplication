module systolic_array #(
    parameter int M     = 2,
    parameter int N     = 2,
    parameter int DATA_W= 8,
    parameter int ACC_W = 2 * DATA_W
)(
    input logic clk,
    input logic rst,
    input logic clear_acc,

    input logic [DATA_W-1:0] a_input [M],
    input logic [DATA_W-1:0] b_input [N],

    output logic [ACC_W-1:0] c_output [M][N]
);

    logic [DATA_W-1:0] a_wire [M][N];
    logic [DATA_W-1:0] b_wire [M][N];

    logic [DATA_W-1:0] a_out [M][N];
    logic [DATA_W-1:0] b_out [M][N];

    logic [ACC_W-1:0] acc [M][N];

    genvar i, j;


    generate
        for(i=0; i < M; i++) begin : ROW
            for(j=0; j < N; j++) begin : COL
                
                if(j == 0) begin
                    assign a_wire[i][j] = a_input[i];
                end
                else begin
                    assign a_wire[i][j] = a_out[i][j-1];
                end

                if(i==0) begin
                    assign b_wire[i][j] = b_input[j];
                end
                else begin
                    assign b_wire[i][j] = b_out[i-1][j];
                end

                systolic_pe #(
                    .DATA_W(DATA_W),
                    .ACC_W(ACC_W)
                ) pe_inst (
                    .clk    (clk),
                    .rst    (rst),
                    .clear_acc (clear_acc),

                    .a_in   (a_wire[i][j]),
                    .b_in   (b_wire[i][j]),

                    .a_out  (a_out[i][j]),
                    .b_out  (b_out[i][j]),

                    .acc    (acc[i][j])
                );

                assign c_output[i][j] = acc[i][j];
            end
        end
    endgenerate
endmodule