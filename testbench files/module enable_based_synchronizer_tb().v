module enable_based_synchronizer_tb();

parameter DATA_WIDTH = 5;

reg clk_1, clk_2;
reg rst_n;
reg en;
reg [DATA_WIDTH-1:0] data_in;
wire [DATA_WIDTH-1:0] data_out;

initial begin
    clk_1 = 0;
    clk_2 = 0;
    rst_n = 1;
    data_in = 0;
    en = 0;
    #10;
    rst_n = 0;
    #10;
    rst_n = 1;
    @(posedge clk_1)
    en = 1;
	#0.5;
    data_in[0] = 1'b1;
    #2;
    data_in[2] = 1'b1;
    #4;
    data_in[3] = 1'b1;
    #100;
end

always #8 clk_1 = !clk_1;
always #4 clk_2 = !clk_2;

enable_based_synchronizer #(.DATA_WIDTH(DATA_WIDTH)) enable_based_synchronizer_inst(
.clk_1(clk_1), 
.clk_2(clk_2),
.rst_n(rst_n),
.en(en),
.data_in(data_in),
.data_out(data_out)
);

endmodule