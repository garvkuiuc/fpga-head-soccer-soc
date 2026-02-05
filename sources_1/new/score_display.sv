module score_display (
    input  logic        clk,
    input  logic [9:0]  DrawX,
    input  logic [9:0]  DrawY,
    input  logic [3:0]  score_p1,
    input  logic [3:0]  score_p2,
    output logic [3:0]  red,
    output logic [3:0]  green,
    output logic [3:0]  blue,
    output logic        active
);

    localparam int DIGIT_W = 8;
    localparam int DIGIT_H = 8;
    localparam int SCALE    = 8;

    localparam int DISP_W = DIGIT_W * SCALE; // 64
    localparam int DISP_H = DIGIT_H * SCALE; // 64

    // Updated again: shifted up and away from center
    localparam int P1_X = 235 - 10 + 3; // move 3px closer to center
    localparam int P1_Y = 60 - 10;

    localparam int P2_X = 341 + 10 - 3; // move 3px closer to center
    localparam int P2_Y = 60 - 10;

    logic show_p1, show_p2;
    assign show_p1 = (DrawX >= P1_X) && (DrawX < P1_X + DISP_W) &&
                     (DrawY >= P1_Y) && (DrawY < P1_Y + DISP_H);
    assign show_p2 = (DrawX >= P2_X) && (DrawX < P2_X + DISP_W) &&
                     (DrawY >= P2_Y) && (DrawY < P2_Y + DISP_H);

    logic [2:0] src_x, src_y;
    always_comb begin
        if (show_p1) begin
            src_x = (DrawX - P1_X) / SCALE;
            src_y = (DrawY - P1_Y) / SCALE;
        end else if (show_p2) begin
            src_x = (DrawX - P2_X) / SCALE;
            src_y = (DrawY - P2_Y) / SCALE;
        end else begin
            src_x = 3'd0;
            src_y = 3'd0;
        end
    end

    logic [3:0] char;
    always_comb begin
        if (show_p1) char = score_p1;
        else if (show_p2) char = score_p2;
        else              char = 4'd0;
    end

    logic [7:0] pixel_data;
    score_rom rom (
        .char   (char),
        .row    (src_y),
        .pixels (pixel_data)
    );

    logic bit_on;
    assign bit_on = (show_p1 && pixel_data[7 - src_x]) ||
                    (show_p2 && pixel_data[7 - src_x]);

    assign active = bit_on;
    assign red    = bit_on ? 4'hF : 4'h0;
    assign green  = bit_on ? 4'hF : 4'h0;
    assign blue   = bit_on ? 4'h0 : 4'h0;

endmodule
