module bin2gray(
    input  wire [3:0] i_bin,
    output reg  [3:0] o_gray
);

    always@(*) begin
        case(i_bin)
            4'b0000: o_gray = 4'b0000;
            4'b0001: o_gray = 4'b0001;
            4'b0010: o_gray = 4'b0011;
            4'b0011: o_gray = 4'b0010;
            4'b0100: o_gray = 4'b0110;
            4'b0101: o_gray = 4'b0111;
            4'b0110: o_gray = 4'b0101;
            4'b0111: o_gray = 4'b0100;
            4'b1000: o_gray = 4'b1100;
            4'b1001: o_gray = 4'b1101;
            4'b1010: o_gray = 4'b1111;
            4'b1011: o_gray = 4'b1110;
            4'b1100: o_gray = 4'b1010;
            4'b1101: o_gray = 4'b1011;
            4'b1110: o_gray = 4'b1001;
            4'b1111: o_gray = 4'b1000;
            default: o_gray = 4'b0000;
        endcase
    end

endmodule
