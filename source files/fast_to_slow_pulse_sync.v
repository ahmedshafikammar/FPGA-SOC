module fast_to_slow_pulse_sync(
input fast_clk, slow_clk,
input rst_n,
input pulse_fast_in,
output pulse_slow_out
);

reg mux_1_out, mux_2_out;
wire ack_sync;
reg req, destination_reg;
wire slow_sync_out, fast_sync_out;
wire ack;

always @(*) begin
    if(pulse_fast_in == 1) begin
        mux_1_out = 1;
    end else begin
        mux_1_out = mux_2_out;
    end
end

always @(*) begin
    if(ack_sync == 1) begin
        mux_2_out = 0;
    end else begin
        mux_2_out = req;
    end
end

always @(posedge fast_clk or negedge rst_n) begin
    if(!rst_n) begin
        req <= 0;
    end else begin
        req <= mux_1_out;
    end
end

double_ff_sync slow_sync_inst (
.clk(slow_clk), 
.rst_n(rst_n),
.data_in(req),
.data_out(slow_sync_out)
);

always @(posedge slow_clk or negedge rst_n) begin
    if(!rst_n) begin
        destination_reg <= 0;
    end else begin
        destination_reg <= slow_sync_out;
    end
end

assign pulse_slow_out = ( !destination_reg & slow_sync_out );

assign ack = destination_reg;

double_ff_sync fast_sync_inst (
.clk(fast_clk), 
.rst_n(rst_n),
.data_in(ack),
.data_out(fast_sync_out)
);

assign ack_sync = fast_sync_out;

endmodule