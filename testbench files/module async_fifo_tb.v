module async_fifo_tb;  

    parameter DATA_WIDTH=4;
    parameter FIFO_DEPTH=8;
    
    reg                     i_rst_n;
    reg                     i_wr_clk;
    reg                     i_wr_en;
    reg [DATA_WIDTH-1:0]    i_wr_data;
    reg                     i_rd_clk;
    reg                     i_rd_en;
    wire [DATA_WIDTH-1:0]   o_rd_data;
    wire                    o_full;
    wire                    o_empty;
    
    integer i;
    
    initial begin
        i_wr_clk = 0;
        i_rd_clk = 0;
        i_rst_n = 1;
        i_wr_en = 0;
        i_wr_data = 0;
        i_rd_en = 0;
        #20 i_rst_n = 0;
        #20 i_rst_n = 1;
        #20 
        for (i=0;i<8;i=i+1)begin
            @(negedge i_wr_clk)
            i_wr_en = 1'b1;
            i_wr_data = i+2;
        end
        @(negedge i_wr_clk) i_wr_en = 1'b0;
        
        @(negedge i_rd_clk) i_rd_en = 1'b1;
        for (i=0;i<8;i=i+1)begin
            @(negedge i_rd_clk)
            $display("rd_data at addr %0d is %0d",i,o_rd_data);
        end
        @(negedge i_rd_clk) i_rd_en = 1'b0;
        #50 $finish;
    end
    
    always #5  i_rd_clk = ~i_rd_clk;
    always #10 i_wr_clk = ~i_wr_clk;
    
    async_fifo #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) u_async_fifo (
        .i_rst_n(i_rst_n), .i_wr_clk(i_wr_clk), .i_wr_en(i_wr_en),
        .i_wr_data(i_wr_data), .i_rd_clk(i_rd_clk), .i_rd_en(i_rd_en),
        .o_rd_data(o_rd_data), .o_full(o_full), .o_empty(o_empty)
    );
    
endmodule
