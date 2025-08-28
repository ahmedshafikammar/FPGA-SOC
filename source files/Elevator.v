`timescale 1ns/1ps

module elevator_controller #(
    parameter CLK_HZ        = 50_000_000,
    parameter SEC_PER_FLOOR = 2,
    parameter DOOR_OPEN_SEC = 2
)(
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [4:0]  i_req_ext,
    input  wire [4:0]  i_req_inter,
    input  wire        i_stop,
    output reg  [2:0]  o_current_floor,
    output reg         o_up,
    output reg         o_down,
    output reg         o_door
);

    localparam CYCLES_PER_FLOOR = CLK_HZ * SEC_PER_FLOOR;
    localparam CYCLES_DOOR      = CLK_HZ * DOOR_OPEN_SEC;

    parameter S_IDLE      = 3'd0;
    parameter S_MOVE_UP   = 3'd1;
    parameter S_MOVE_DOWN = 3'd2;
    parameter S_DOOR      = 3'd3;
    parameter S_STOP      = 3'd4;

    reg [2:0] state, state_next;

    reg stop_q;
    reg [4:0] req_ext_q, req_int_q;
    wire [4:0] req_ext_rise = i_req_ext  & ~req_ext_q;
    wire [4:0] req_int_rise = i_req_inter & ~req_int_q;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            stop_q      <= 0;
            req_ext_q   <= 0;
            req_int_q   <= 0;
        end else begin
            stop_q      <= i_stop;
            req_ext_q   <= i_req_ext;
            req_int_q   <= i_req_inter;
        end
    end

    wire stop_rise = i_stop & ~stop_q;

    reg stop_mode;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            stop_mode <= 0;
        else if (stop_rise)
            stop_mode <= ~stop_mode;
    end

    reg [4:0] pending;

    reg [2:0] queue [0:15];
    reg [3:0] q_head, q_tail;
    wire q_empty = (q_head == q_tail);

    task q_push(input [2:0] floor);
    begin
        queue[q_tail] <= floor;
        q_tail <= q_tail + 1'b1;
    end
    endtask

    reg [2:0] q_out;
    task q_pop;
    begin
        q_out <= queue[q_head];
        q_head <= q_head + 1'b1;
    end
    endtask

    integer i;
    wire [4:0] rises = (req_ext_rise | req_int_rise) & ~pending;
    reg idle_phase;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            pending <= 0;
            q_head <= 0;
            q_tail <= 0;
        end else begin
            if (rises != 0) begin
                integer count;
                count = rises[0]+rises[1]+rises[2]+rises[3]+rises[4];
                if (idle_phase && count > 1) begin
                    for (i=4; i>=0; i=i-1) begin
                        if (rises[i]) begin
                            q_push(i[2:0]);
                            pending[i] <= 1;
                        end
                    end
                end else begin
                    for (i=0; i<5; i=i+1) begin
                        if (rises[i]) begin
                            q_push(i[2:0]);
                            pending[i] <= 1;
                        end
                    end
                end
            end
        end
    end

    reg [31:0] timer;
    reg [2:0] target_floor;
    reg have_target;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= S_IDLE;
            o_current_floor <= 0;
            o_up <= 0;
            o_down <= 0;
            o_door <= 0;
            timer <= 0;
            target_floor <= 0;
            have_target <= 0;
        end else begin
            state <= state_next;
        end
    end

    always @(*) begin
        state_next = state;
        o_up   = 0;
        o_down = 0;
        o_door = 0;
        idle_phase = 0;
    end

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            timer <= 0;
            have_target <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    idle_phase <= ~stop_mode;
                    if (stop_mode) begin
                        state_next <= S_STOP;
                    end else begin
                        if (pending[o_current_floor]) begin
                            state_next <= S_DOOR;
                            timer <= 0;
                            o_door <= 1;
                            pending[o_current_floor] <= 0;
                            if (!q_empty && queue[q_head] == o_current_floor)
                                q_head <= q_head + 1'b1;
                        end else if (!q_empty) begin
                            q_pop();
                            target_floor <= q_out;
                            have_target <= 1;
                            if (q_out > o_current_floor)
                                state_next <= S_MOVE_UP;
                            else if (q_out < o_current_floor)
                                state_next <= S_MOVE_DOWN;
                            else begin
                                state_next <= S_DOOR;
                                timer <= 0;
                                o_door <= 1;
                            end
                            pending[q_out] <= 0;
                            timer <= 0;
                        end
                    end
                end

                S_MOVE_UP: begin
                    if (stop_mode) begin
                        state_next <= S_STOP;
                    end else begin
                        o_up <= 1;
                        if (timer >= CYCLES_PER_FLOOR-1) begin
                            timer <= 0;
                            if (o_current_floor < 4)
                                o_current_floor <= o_current_floor + 1;
                            if (o_current_floor == target_floor)
                                state_next <= S_DOOR;
                        end else
                            timer <= timer + 1;
                    end
                end

                S_MOVE_DOWN: begin
                    if (stop_mode) begin
                        state_next <= S_STOP;
                    end else begin
                        o_down <= 1;
                        if (timer >= CYCLES_PER_FLOOR-1) begin
                            timer <= 0;
                            if (o_current_floor > 0)
                                o_current_floor <= o_current_floor - 1;
                            if (o_current_floor == target_floor)
                                state_next <= S_DOOR;
                        end else
                            timer <= timer + 1;
                    end
                end

                S_DOOR: begin
                    if (stop_mode) begin
                        state_next <= S_STOP;
                    end else begin
                        o_door <= 1;
                        if (timer >= CYCLES_DOOR-1) begin
                            timer <= 0;
                            state_next <= S_IDLE;
                        end else
                            timer <= timer + 1;
                    end
                end

                S_STOP: begin
                    if (!stop_mode)
                        state_next <= S_IDLE;
                end
            endcase
        end
    end

endmodule
