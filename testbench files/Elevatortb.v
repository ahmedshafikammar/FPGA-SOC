 `timescale 1ns/1ps

module tb_elevator_controller;

    parameter CLK_HZ        = 10_000;
    parameter SEC_PER_FLOOR = 1;
    parameter DOOR_OPEN_SEC = 1;

    reg        clk;
    reg        rst_n;
    reg  [4:0] req_ext;
    reg  [4:0] req_int;
    reg        stop_btn;
    wire [2:0] cur_floor;
    wire       up, down, door;

    elevator_controller #(
        .CLK_HZ(CLK_HZ),
        .SEC_PER_FLOOR(SEC_PER_FLOOR),
        .DOOR_OPEN_SEC(DOOR_OPEN_SEC)
    ) dut (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_req_ext(req_ext),
        .i_req_inter(req_int),
        .i_stop(stop_btn),
        .o_current_floor(cur_floor),
        .o_up(up),
        .o_down(down),
        .o_door(door)
    );

    always #50 clk = ~clk;

    task press_req;
        input integer floor;
        input integer internal;
    begin
        if (internal) begin
            req_int[floor] = 1'b1;
            #100;
            req_int[floor] = 1'b0;
        end else begin
            req_ext[floor] = 1'b1;
            #100;
            req_ext[floor] = 1'b0;
        end
    end
    endtask

    task press_stop;
    begin
        stop_btn = 1'b1;
        #100;
        stop_btn = 1'b0;
    end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        req_ext = 5'b00000;
        req_int = 5'b00000;
        stop_btn = 0;

        #500;
        rst_n = 1;

        req_ext[1] = 1; req_ext[3] = 1;
        #100;
        req_ext = 5'b00000;

        #200000;
        press_req(2, 1);

        #200000;
        press_stop();
        #200000;
        press_stop();

        #200000;
        press_req(0, 0);

        #1000000;

        $stop;
    end

endmodule
