module multiplier_2stage #(
    parameter WIDTH_A = 18,
    parameter WIDTH_B = 18,
    parameter WIDTH_P = 36
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [WIDTH_A-1:0]    A,
    input  wire [WIDTH_B-1:0]    B,
    output reg  [WIDTH_P-1:0]    P
);

    reg [WIDTH_A-1:0] A_reg;
    reg [WIDTH_B-1:0] B_reg;
    reg [WIDTH_P-1:0] mult_result;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            A_reg <= 0;
            B_reg <= 0;
        end else begin
            A_reg <= A;
            B_reg <= B;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mult_result <= 0;
        end else begin
            mult_result <= A_reg * B_reg;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            P <= 0;
        end else begin
            P <= mult_result;
        end
    end

endmodule
