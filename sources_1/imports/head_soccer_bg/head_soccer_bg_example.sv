module head_soccer_bg_example (
    input  logic        vga_clk,
    input  logic [9:0]  DrawX, DrawY,
    input  logic        blank,

    input  logic [9:0]  Char1X, Char1Y, Char1S,
    input  logic [9:0]  Char2X, Char2Y, Char2S,
    input  logic [9:0]  BallX, BallY, BallS,

    output logic [3:0]  red, green, blue
);

//logic [11:0] rom_address;
logic [2:0] rom_q;

logic [3:0] palette_red, palette_green, palette_blue;

logic negedge_vga_clk;

// read from ROM on negedge, set pixel on posedge
assign negedge_vga_clk = ~vga_clk;

// address into the rom = (x*xDim)/640 + ((y*yDim)/480) * xDim
// this will stretch out the sprite across the entire screen

logic [11:0] bg_rom_addr;
logic [2:0] bg_rom_q;
logic [3:0] bg_r, bg_g, bg_b;
    
    
//assign rom_address = ((DrawX * 50) / 640) + (((DrawY * 50) / 480) * 50);

//wire [11:0] bg_rom_addr;
assign bg_rom_addr = ((DrawX * 50) / 640) + (((DrawY * 50) / 480) * 50);

//always_ff @ (posedge vga_clk) begin
//	if (blank) begin
//		red_out   <= palette_red;
//		green_out <= palette_green;
//		blue_out  <= palette_blue;
//		active    <= 1;
//	end else begin
//		red_out   <= 4'h0;
//		green_out <= 4'h0;
//		blue_out  <= 4'h0;
//		active    <= 0;
//	end
//end

head_soccer_bg_rom bg_rom (
        .clka   (negedge_vga_clk),
        .addra  (bg_rom_addr),
        .douta  (bg_rom_q)
 );

head_soccer_bg_palette bg_palette (
        .index  (bg_rom_q),
        .red    (bg_r),
        .green  (bg_g),
        .blue   (bg_b)
 );
 
 parameter CHAR1_W = 40;
    parameter CHAR1_H = 50;
    logic [10:0] c1_rom_addr;
    logic [2:0]  c1_rom_q;
    logic [3:0]  c1_r, c1_g, c1_b;
    logic        c1_on;

    assign c1_on = (DrawX >= Char1X) && (DrawX < Char1X + CHAR1_W) &&
                   (DrawY >= Char1Y) && (DrawY < Char1Y + CHAR1_H);

    logic [6:0] c1_x = DrawX - Char1X;
    logic [6:0] c1_y = DrawY - Char1Y;
    assign c1_rom_addr = c1_y * CHAR1_W + c1_x;

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

    // --- CHARACTER 2
    parameter CHAR2_W = 40;
    parameter CHAR2_H = 50;
    logic [10:0] c2_rom_addr;
    logic [2:0]  c2_rom_q;
    logic [3:0]  c2_r, c2_g, c2_b;
    logic        c2_on;

    assign c2_on = (DrawX >= Char2X) && (DrawX < Char2X + CHAR2_W) &&
                   (DrawY >= Char2Y) && (DrawY < Char2Y + CHAR2_H);

    logic [6:0] c2_x = DrawX - Char2X;
    logic [6:0] c2_y = DrawY - Char2Y;
    assign c2_rom_addr = c2_y * CHAR2_W + c2_x;

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

    // --- BALL SPRITE (if using ball sprite ROM later)
    // For now, skip ROM. Placeholder:
    logic ball_on;
    assign ball_on = (DrawX >= BallX - BallS) && (DrawX < BallX + BallS) &&
                     (DrawY >= BallY - BallS) && (DrawY < BallY + BallS);
    logic [3:0] ball_r = 4'hF, ball_g = 4'hE, ball_b = 4'h0;

    // --- PRIORITY DRAWING LOGIC
    always_ff @(posedge vga_clk) begin
        if (blank) begin
            if (c1_on && c1_rom_q != 3'b000) begin // optional: skip color 0 for transparency
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
            red <= 0; green <= 0; blue <= 0;
        end
    end

endmodule
