module enable_based_synchronizer #(parameter DATA_WIDTH = 4) (
input clk_1, clk_2,
input rst_n,
input en,
input [DATA_WIDTH-1:0] data_in,
output [DATA_WIDTH-1:0] data_out
);

reg [DATA_WIDTH-1:0] data_source_reg; 
reg en_source_reg;

reg [DATA_WIDTH-1:0] data_destination_reg;
wire en_sync_out;


/////////////////// 1st domain ///////////////////
always @(posedge clk_1 or negedge rst_n) begin
    if(!rst_n) begin
        data_source_reg <= 0;
    end else begin
        data_source_reg <= data_in;
    end
end

always @(posedge clk_1 or negedge rst_n) begin
    if(!rst_n) begin
        en_source_reg <= 0;
    end else begin
        en_source_reg <= en;
    end
end

/////////////////// 2nd domain ///////////////////
double_ff_sync sync_inst (
.clk(clk_2), 
.rst_n(rst_n),
.data_in(en_source_reg),
.data_out(en_sync_out)
);

always @(posedge clk_2 or negedge rst_n) begin
    if(!rst_n) begin
        data_destination_reg <= 0;
    end else begin
        if(en_sync_out) begin
            data_destination_reg <= data_source_reg;
        end else begin
            data_destination_reg <= data_destination_reg;
        end
    end 
end

assign data_out = data_destination_reg;

endmodule