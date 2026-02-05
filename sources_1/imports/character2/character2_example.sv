module character2_example (
	input logic vga_clk,
	input logic [9:0] DrawX, DrawY,
	input  logic [9:0] CharX, CharY, // ADDED THIS IN TO ACCOUNT FOR DYNAMIC MOVEMENT
	input logic blank,
	output logic [3:0] red_out, green_out, blue_out,
    output logic       active
);

logic [10:0] rom_address;
logic [2:0] rom_q;

logic [3:0] palette_red, palette_green, palette_blue;

logic negedge_vga_clk;

// read from ROM on negedge, set pixel on posedge
assign negedge_vga_clk = ~vga_clk;

// address into the rom = (x*xDim)/640 + ((y*yDim)/480) * xDim
// this will stretch out the sprite across the entire screen


// assign rom_address = ((DrawX * 40) / 640) + (((DrawY * 50) / 480) * 40);

parameter [6:0] CharWidth = 40;
parameter [6:0] CharHeight = 50;

logic [5:0] sprite_x, sprite_y;
assign sprite_x = DrawX - CharX;
assign sprite_y = DrawY - CharY;

assign rom_address = sprite_y * CharWidth + sprite_x;

//always_ff @ (posedge vga_clk) begin
//	red <= 4'h0;
//	green <= 4'h0;
//	blue <= 4'h0;

//	if (blank) begin
//		red <= palette_red;
//		green <= palette_green;
//		blue <= palette_blue;
//	end
//end

always_ff @ (posedge vga_clk) begin
    if (blank &&
        (DrawX >= CharX) && (DrawX < CharX + CharWidth) &&
        (DrawY >= CharY) && (DrawY < CharY + CharHeight)) begin
        
        red_out   <= palette_red;
        green_out <= palette_green;
        blue_out  <= palette_blue;
        active    <= 1;
    end else begin
        red_out   <= 4'h0;
        green_out <= 4'h0;
        blue_out  <= 4'h0;
        active    <= 0;
    end
end

character2_rom character2_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address),
	.douta       (rom_q)
);

character2_palette character2_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

endmodule
