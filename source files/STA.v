module modified_top (
    input i_clk,
    input i_rst_n,
    input wire i_a,
    input wire i_b,
    output reg o_y
);

    reg a_r, b_r;
    wire y_w;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            a_r <= 0;
            b_r <= 0;
            o_y <= 0;
        end else begin
            a_r <= i_a;
            b_r <= i_b;
            o_y <= y_w;
        end
    end

    modified_large_combinational_logic comb_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_a(a_r),
        .i_b(b_r),
        .o_y(y_w)
    );

endmodule
