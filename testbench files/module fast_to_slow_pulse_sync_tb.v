module fast_to_slow_pulse_sync_tb();

reg slow_clk, fast_clk;
reg rst_n;
reg pulse_fast_in;
wire pulse_slow_out;

initial begin
    fast_clk = 0;
    slow_clk = 0;
    rst_n = 1;
    pulse_fast_in = 0;
    #10;
    rst_n = 0;
    #10;
    rst_n = 1;
    @(posedge fast_clk)
    pulse_fast_in = 1;
    @(posedge fast_clk)
    pulse_fast_in = 0;
    #100;
end

always #3 fast_clk = !fast_clk;
always #8 slow_clk = !slow_clk;

fast_to_slow_pulse_sync slow_to_fast_pulse_sync_inst(
.fast_clk(fast_clk),
.slow_clk(slow_clk), 
.rst_n(rst_n),
.pulse_fast_in(pulse_fast_in),
.pulse_slow_out(pulse_slow_out)
);

endmodule