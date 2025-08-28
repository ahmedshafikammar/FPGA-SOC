module async_fifo #(parameter DATA_WIDTH=4, parameter FIFO_DEPTH=8)(
    input  wire                     i_rst_n,
    input  wire                     i_wr_clk,
    input  wire                     i_wr_en,
    input  wire [DATA_WIDTH-1:0]    i_wr_data,
    input  wire                     i_rd_clk,
    input  wire                     i_rd_en,
    output wire [DATA_WIDTH-1:0]    o_rd_data,
    output wire                     o_full,
    output wire                     o_empty
);

    parameter PTR_WIDTH = $clog2(FIFO_DEPTH);

    wire enable_wr = (i_wr_en && !o_full);
    wire enable_rd = (i_rd_en && !o_empty);

    wire [PTR_WIDTH:0] rdptr, wrptr;
    wire [PTR_WIDTH:0] rdptr_sync, wrptr_sync;
    wire [PTR_WIDTH:0] rdptr_b2g_out, wrptr_b2g_out;
    wire [PTR_WIDTH:0] rdptr_g2b_out, wrptr_g2b_out;
    wire [PTR_WIDTH-1:0] wraddr, rdaddr;

    fifo_mem #(.MEM_DEPTH(FIFO_DEPTH), .MEM_WIDTH(DATA_WIDTH)) u_fifo_mem (
        .i_rst_n(i_rst_n), .i_wr_clk(i_wr_clk), .i_wr_en(enable_wr),
        .i_wr_data(i_wr_data), .i_wr_addr(wraddr),
        .i_rd_clk(i_rd_clk), .i_rd_en(enable_rd),
        .i_rd_addr(rdaddr), .o_rd_data(o_rd_data)
    );

    wrptr_full #(.PTR_WIDTH(PTR_WIDTH)) u_wrptr_full (
        .i_wr_clk(i_wr_clk), .i_rst_n(i_rst_n), .i_wr_en(i_wr_en),
        .i_rdptr_sync(rdptr_g2b_out),
        .o_wrptr(wrptr), .o_wraddr(wraddr), .o_full_flag(o_full)
    );

    bin2gray u_wrptr_bin2gray(.i_bin(wrptr), .o_gray(wrptr_b2g_out));

    syn2stage #(.SIG_WIDTH(DATA_WIDTH)) u_wrptr_syn(
        .i_clk(i_rd_clk), .i_rst_n(i_rst_n),
        .i_sig(wrptr_b2g_out), .o_sig_sync(wrptr_sync)
    );

    gray2bin u_wrptr_gray2bin(.i_gray(wrptr_sync), .o_bin(wrptr_g2b_out));

    rdptr_empty #(.PTR_WIDTH(PTR_WIDTH)) u_rdptr_empty (
        .i_rd_clk(i_rd_clk), .i_rst_n(i_rst_n), .i_rd_en(i_rd_en),
        .i_wrptr_sync(wrptr_g2b_out),
        .o_rdptr(rdptr), .o_rdaddr(rdaddr), .o_empty_flag(o_empty)
    );

    bin2gray u_rdptr_bin2gray(.i_bin(rdptr), .o_gray(rdptr_b2g_out));

    syn2stage #(.SIG_WIDTH(DATA_WIDTH)) u_rdptr_syn(
        .i_clk(i_wr_clk), .i_rst_n(i_rst_n),
        .i_sig(rdptr_b2g_out), .o_sig_sync(rdptr_sync)
    );

    gray2bin u_rdptr_gray2bin(.i_gray(rdptr_sync), .o_bin(rdptr_g2b_out));

endmodule
