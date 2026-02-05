//-------------------------------------------------------------------------
// ball_control.sv
//   • enhanced bounce and slower lateral movement
//-------------------------------------------------------------------------
module ball_control (
    input  logic        Reset,       // global or goal reset
    input  logic        frame_clk,   // vsync tick
    input  logic [9:0]  Char1X,      // player 1
    input  logic [9:0]  Char1Y,
    input  logic [9:0]  Char1S,
    input  logic [9:0]  Char2X,      // player 2
    input  logic [9:0]  Char2Y,
    input  logic [9:0]  Char2S,
    output logic [9:0]  BallX,
    output logic [9:0]  BallY,
    output logic [9:0]  BallS
);

    // parameters
    parameter int SCREEN_W = 640;
    parameter int SIZE     = 20;
    localparam int FLOOR_Y = 400;
    localparam int GOAL_W  = 80;
    localparam int GOAL_H  = 150;

    // updated physics constants
    localparam int GRAVITY = 1;     // gravity remains light
    localparam int KICK_H  = 5;     // slower lateral kicks
    localparam int KICK_V  = 12;    // higher vertical kicks
    localparam int FRICT   = 1;     // floor friction

    assign BallS = SIZE;

    logic signed [10:0] x, y, vx, vy;
    logic signed [10:0] nx, ny, nvx, nvy;

    always_ff @(posedge frame_clk) begin
        if (Reset) begin
            x  <= (SCREEN_W - SIZE) / 2;
            y  <= (FLOOR_Y - SIZE) / 2;
            vx <= 0;
            vy <= 0;
        end else begin
            // gravity
            nvy = vy + GRAVITY;

            // friction (only on floor)
            if (y >= FLOOR_Y - SIZE) begin
                if      (vx > 0) nvx = vx - FRICT;
                else if (vx < 0) nvx = vx + FRICT;
                else             nvx = 0;
            end else begin
                nvx = vx;
            end

            // collision with player 1
            if ((x + SIZE > Char1X) && (x < Char1X + Char1S) &&
                (y + SIZE > Char1Y) && (y < Char1Y + Char1S)) begin
                nvx = (x < Char1X) ? -KICK_H : KICK_H;
                nvy = -KICK_V;
            end
            // collision with player 2
            else if ((x + SIZE > Char2X) && (x < Char2X + Char2S) &&
                     (y + SIZE > Char2Y) && (y < Char2Y + Char2S)) begin
                nvx = (x < Char2X) ? -KICK_H : KICK_H;
                nvy = -KICK_V;
            end

            // integrate
            nx = x + nvx;
            ny = y + nvy;

            // wall bounce
            if (nx < 0) begin
                nx  = 0;
                nvx = -nvx;
            end else if (nx > SCREEN_W - SIZE) begin
                nx  = SCREEN_W - SIZE;
                nvx = -nvx;
            end

            // floor bounce with improved bounce energy
            if (ny >= FLOOR_Y - SIZE) begin
                ny = FLOOR_Y - SIZE;
                if (nvy > 1 || nvy < -1)
                    nvy = -((nvy * 3) / 4);  // preserve ~75% of bounce
                else
                    nvy = 0;
            end

            // crossbar bounce
            if ((nx < GOAL_W) || (nx + SIZE > SCREEN_W - GOAL_W)) begin
                // bounce from below
                if ((ny <= FLOOR_Y - GOAL_H) && (y > FLOOR_Y - GOAL_H)) begin
                    ny  = FLOOR_Y - GOAL_H;
                    nvy = -nvy;
                end
                // bounce from above
                else if ((y < FLOOR_Y - GOAL_H) && (ny >= FLOOR_Y - GOAL_H)) begin
                    ny  = FLOOR_Y - GOAL_H;
                    nvy = -nvy;
                end
            end

            // ceiling clamp
            if (ny < 0) begin
                ny  = 0;
                nvy = 0;
            end

            // update state
            x  <= nx;
            y  <= ny;
            vx <= nvx;
            vy <= nvy;
        end
    end

    // output registers
    always_ff @(posedge frame_clk) begin
        BallX <= x;
        BallY <= y;
    end

endmodule
