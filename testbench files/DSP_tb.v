module multiplier_2stage_tb;

    parameter WIDTH_A = 18;
    parameter WIDTH_B = 18;
    parameter WIDTH_P = 36;

    reg clk, rst_n;
    reg [WIDTH_A-1:0] A;
    reg [WIDTH_B-1:0] B;
    wire [WIDTH_P-1:0] P;

    multiplier_2stage #(.WIDTH_A(WIDTH_A), .WIDTH_B(WIDTH_B), .WIDTH_P(WIDTH_P)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .A(A),
        .B(B),
        .P(P)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        A = 0; B = 0;
        #12 rst_n = 1;

        @(negedge clk) A = 10; B = 20;
        @(negedge clk) A = 123; B = 45;
        @(negedge clk) A = 300; B = 300;
        @(negedge clk) A = 500; B = 2;

        #100 $finish;
    end

    initial begin
        $monitor("Time=%0t | A=%d, B=%d => P=%d",$time,A,B,P);
    end

endmodule
