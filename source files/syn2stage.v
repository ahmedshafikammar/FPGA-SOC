module syn2stage #(parameter SIG_WIDTH = 4)(
    input  wire                 i_clk,
    input  wire                 i_rst_n,
    input  wire [SIG_WIDTH-1:0] i_sig,
    output reg  [SIG_WIDTH-1:0] o_sig_sync
);

    reg [SIG_WIDTH-1:0] sig_r;
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            sig_r      <= 3'b0;
            o_sig_sync <= 3'b0;
        end else begin
            sig_r      <= i_sig;
            o_sig_sync <= sig_r;
        end
    end

endmodule
