RTL Code
module pwm #(parameter R=4)( // resolution
input i_clk, i_rst_n,
input [R-1:0] i_duty,
output o_pwm
);
reg [R-1:0] counter_r;
always@(posedge i_clk) begin
if(!i_rst_n) counter_r <= 0;
else counter_r <= counter_r + 1;
end
assign o_pwm = (counter_r < i_duty);
endmodule
Testbench
module tb();
reg i_clk, i_rst_n;
reg [3:0] i_duty;
wire o_pwm;
initial begin
i_clk = 0;
i_rst_n = 1;
i_duty = 4'd13;
#10;
i_rst_n = 0;
#10;
i_rst_n = 1;
#500
i_duty = 15;
#500;
end
always #5 i_clk = !i_clk ;
pwm dut(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_duty(i_duty),
.o_pwm(o_pwm));
endmodule