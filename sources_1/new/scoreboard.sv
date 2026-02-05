module scoreboard (
    input  logic        clk,
    input  logic        reset,

    input  logic        goal_player1,
    input  logic        goal_player2,

    output logic [3:0]  score_p1,
    output logic [3:0]  score_p2
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            score_p1 <= 4'd0;
            score_p2 <= 4'd0;
        end else begin
            if (goal_player1 && score_p1 < 4'd9)
                score_p1 <= score_p1 + 1;

            if (goal_player2 && score_p2 < 4'd9)
                score_p2 <= score_p2 + 1;

            if (score_p1 == 4'd9) begin
                score_p1 <= 4'd0;
                score_p2 <= 4'd0;
            end else if (score_p2 == 4'd9) begin
                score_p1 <= 4'd0;
                score_p2 <= 4'd0;
            end
        end
    end

endmodule
