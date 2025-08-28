module rdptr_empty #(parameter PTR_WIDTH=3)(
    input  wire                 i_rd_clk,
    input  wire                 i_rst_n,
    input  wire                 i_rd_en,
    input  wire [PTR_WIDTH:0]   i_wrptr_sync,
    output reg  [PTR_WIDTH:0]   o_rdptr,
    output wire [PTR_WIDTH-1:0] o_rdaddr,
    output wire                 o_empty_flag
);

    always @ (posedge i_rd_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            o_rdptr <= 'b0;
        end else if(i_rd_en && !o_empty_flag) begin
            o_rdptr <= o_rdptr + 1;
        end
    end
    
    assign o_rdaddr = o_rdptr[PTR_WIDTH-1:0];
    assign o_empty_flag = (o_rdptr == i_wrptr_sync);

endmodule
