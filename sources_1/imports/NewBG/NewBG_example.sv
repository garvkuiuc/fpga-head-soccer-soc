module NewBG_example (
    input  logic        vga_clk,
    input  logic [9:0]  DrawX, DrawY,
    input  logic        blank,

    input  logic [9:0]  Char1X, Char1Y, Char1S,
    input  logic [9:0]  Char2X, Char2Y, Char2S,
    input  logic [9:0]  BallX, BallY, BallS,
    input  logic [3:0]  score_p1,
    input  logic [3:0]  score_p2,

    output logic [3:0]  red, green, blue
);

logic negedge_vga_clk = ~vga_clk;

// Background ROM
parameter BG_W = 640;
parameter BG_H = 480;
logic [18:0] bg_rom_addr = DrawY * BG_W + DrawX;
logic [2:0]  bg_rom_q;
logic [3:0]  bg_r, bg_g, bg_b;

NewBG_rom bg_rom (
    .clka   (negedge_vga_clk),
    .addra  (bg_rom_addr),
    .douta  (bg_rom_q)
);

NewBG_palette bg_palette (
    .index  (bg_rom_q),
    .red    (bg_r),
    .green  (bg_g),
    .blue   (bg_b)
);

// Character 1
parameter CHAR1_W = 40;
parameter CHAR1_H = 50;
logic [10:0] c1_rom_addr;
logic [2:0]  c1_rom_q;
logic [3:0]  c1_r, c1_g, c1_b;
logic        c1_on = (DrawX >= Char1X) && (DrawX < Char1X + CHAR1_W) &&
                     (DrawY >= Char1Y) && (DrawY < Char1Y + CHAR1_H);

assign c1_rom_addr = (DrawY - Char1Y) * CHAR1_W + (DrawX - Char1X);

character1_rom c1_rom (
    .clka   (negedge_vga_clk),
    .addra  (c1_rom_addr),
    .douta  (c1_rom_q)
);

character1_palette c1_palette (
    .index(c1_rom_q),
    .red(c1_r),
    .green(c1_g),
    .blue(c1_b)
);

// Character 2
parameter CHAR2_W = 40;
parameter CHAR2_H = 50;
logic [10:0] c2_rom_addr;
logic [2:0]  c2_rom_q;
logic [3:0]  c2_r, c2_g, c2_b;
logic        c2_on = (DrawX >= Char2X) && (DrawX < Char2X + CHAR2_W) &&
                     (DrawY >= Char2Y) && (DrawY < Char2Y + CHAR2_H);

assign c2_rom_addr = (DrawY - Char2Y) * CHAR2_W + (DrawX - Char2X);

character2_rom c2_rom (
    .clka   (negedge_vga_clk),
    .addra  (c2_rom_addr),
    .douta  (c2_rom_q)
);

character2_palette c2_palette (
    .index(c2_rom_q),
    .red(c2_r),
    .green(c2_g),
    .blue(c2_b)
);

// Ball sprite
logic [3:0] ball_r, ball_g, ball_b;
logic       ball_on;

jabooboo_example ball_sprite (
    .vga_clk(vga_clk),
    .DrawX(DrawX),
    .DrawY(DrawY),
    .CharX(BallX),
    .CharY(BallY),
    .blank(blank),
    .red_out(ball_r),
    .green_out(ball_g),
    .blue_out(ball_b),
    .active(ball_on)
);

// Score Display
logic [3:0] score_r, score_g, score_b;
logic       score_active;

score_display score_overlay (
    .clk      (vga_clk),
    .DrawX    (DrawX),
    .DrawY    (DrawY),
    .score_p1 (score_p1),
    .score_p2 (score_p2),
    .red      (score_r),
    .green    (score_g),
    .blue     (score_b),
    .active   (score_active)
);

// Final pixel priority: score > c1 > c2 > ball > bg
always_ff @(posedge vga_clk) begin
    if (blank) begin
        if (score_active) begin
            red   <= score_r;
            green <= score_g;
            blue  <= score_b;
        end else if (c1_on && c1_rom_q != 3'b000) begin
            red   <= c1_r;
            green <= c1_g;
            blue  <= c1_b;
        end else if (c2_on && c2_rom_q != 3'b000) begin
            red   <= c2_r;
            green <= c2_g;
            blue  <= c2_b;
        end else if (ball_on) begin
            red   <= ball_r;
            green <= ball_g;
            blue  <= ball_b;
        end else begin
            red   <= bg_r;
            green <= bg_g;
            blue  <= bg_b;
        end
    end else begin
        red   <= 0;
        green <= 0;
        blue  <= 0;
    end
end

endmodule
