module slow_to_fast_pulse_sync_tb();

reg slow_clk, fast_clk;
reg rst_n;
reg pulse_slow_in;
wire pulse_fast_out;

initial begin
    fast_clk = 0;
    slow_clk = 0;
    rst_n = 1;
    pulse_slow_in = 0;
    #10;
    rst_n = 0;
    #10;
    rst_n = 1;
    @(posedge slow_clk)
    pulse_slow_in = 1;
    @(posedge slow_clk)
    pulse_slow_in = 0;
    #30;
end

always #3 fast_clk = !fast_clk;
always #8 slow_clk = !slow_clk;

slow_to_fast_pulse_sync slow_to_fast_pulse_sync_inst(
.slow_clk(slow_clk), 
.fast_clk(fast_clk),
.rst_n(rst_n),
.pulse_slow_in(pulse_slow_in),
.pulse_fast_out(pulse_fast_out)
);

endmodule