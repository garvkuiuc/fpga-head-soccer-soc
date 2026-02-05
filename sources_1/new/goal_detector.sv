module goal_detector(
  input  logic        clk,       // your vsync/frame clock
  input  logic        Reset,     // global reset
  input  logic [9:0]  BallX,
  input  logic [9:0]  BallY,
  input  logic [9:0]  BallS,     // size of the ball
  output logic        goal_p1,   // left-side goal (Player 2 scores)
  output logic        goal_p2,   // right-side goal (Player 1 scores)
  output logic        reset      // one-cycle goal reset pulse
);

  // must match top-level constants
  localparam int SCREEN_W = 640;
  localparam int GOAL_W   = 80;
  localparam int FLOOR_Y  = 400;

  // internal wires
  logic in_left_goal,  in_right_goal;
  logic in_left_prev,  in_right_prev;

  // updated goal detection: if bottom of ball reaches floor inside goal width
  always_comb begin
    in_left_goal  = (BallX < GOAL_W) &&
                    (BallY + BallS >= FLOOR_Y - 1);
                    
    in_right_goal = (BallX + BallS > SCREEN_W - GOAL_W) &&
                    (BallY + BallS >= FLOOR_Y - 1);
  end

  always_ff @(posedge clk or posedge Reset) begin
    if (Reset) begin
      in_left_prev  <= 1'b0;
      in_right_prev <= 1'b0;
      goal_p1       <= 1'b0;
      goal_p2       <= 1'b0;
      reset         <= 1'b0;
    end else begin
      // rising-edge detection
      goal_p2 <= in_left_goal  && !in_left_prev;  // Player 2 scores on left goal
      goal_p1 <= in_right_goal && !in_right_prev; // Player 1 scores on right goal

      // one-frame reset signal
      reset   <= goal_p1 || goal_p2;

      // update previous state
      in_left_prev  <= in_left_goal;
      in_right_prev <= in_right_goal;
    end
  end

endmodule
