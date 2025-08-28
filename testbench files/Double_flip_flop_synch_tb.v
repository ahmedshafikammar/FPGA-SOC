 `timescale 1ns / 1ps
module double_ff_sync_tb();

reg clk, rst_n;
reg data_in;
wire data_out;

always #5 clk = !clk;

initial begin
    clk = 0;
    rst_n = 1;
    data_in = 0;
    @(negedge clk);
    rst_n = 0;
    @(negedge clk);
	rst_n = 1;
    data_in = 1;
    #20;
end

double_ff_sync sync_inst(
.clk(clk), 
.rst_n(rst_n),
.data_in(data_in),
.data_out(data_out));

endmodule