module wrptr_full #(parameter PTR_WIDTH=3)(
    input  wire                 i_wr_clk,
    input  wire                 i_rst_n,
    input  wire                 i_wr_en,
    input  wire [PTR_WIDTH:0]   i_rdptr_sync,
    output reg  [PTR_WIDTH:0]   o_wrptr,
    output wire [PTR_WIDTH-1:0] o_wraddr,
    output wire                 o_full_flag
);

    always @ (posedge i_wr_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            o_wrptr <= 'b0;
        end else if(i_wr_en && !o_full_flag) begin
            o_wrptr <= o_wrptr + 1;
        end
    end
    
    assign o_wraddr = o_wrptr[PTR_WIDTH-1:0];
    assign o_full_flag = ({~o_wrptr[PTR_WIDTH],o_wrptr[PTR_WIDTH-1:0]} == i_rdptr_sync);

endmodule
