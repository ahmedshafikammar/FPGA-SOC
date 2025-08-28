module slow_to_fast_pulse_sync(
input slow_clk, fast_clk,
input rst_n,
input pulse_slow_in,
output pulse_fast_out
);

reg source_reg, destination_reg;
wire sync_out;


/////////////////// slow domain ///////////////////
always @(posedge slow_clk or negedge rst_n) begin
    if(!rst_n) begin
        source_reg <= 0;
    end else begin
        source_reg <= pulse_slow_in;
    end
end

/////////////////// fast domain ///////////////////
double_ff_sync sync_inst (
.clk(fast_clk), 
.rst_n(rst_n),
.data_in(source_reg),
.data_out(sync_out)
);

always @(posedge fast_clk or negedge rst_n) begin
    if(!rst_n) begin
        destination_reg <= 0;
    end else begin
        destination_reg <= sync_out;
    end
end

/////////////////// output ///////////////////
assign pulse_fast_out = ( !destination_reg & sync_out );

endmodule