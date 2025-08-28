
 `timescale 1ns / 1ps


module double_ff_sync(
input clk, rst_n,
input data_in,
output data_out
);

reg sync_1, sync_2;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sync_1 <= 0;
        sync_2 <= 0;
    end else begin
        sync_1 <= data_in;
        sync_2 <= sync_1;    
    end
end

assign data_out = sync_2;

endmodule