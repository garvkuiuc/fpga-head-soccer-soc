//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Zuofu Cheng   08-19-2023                               --
//                                                                       --
//    Fall 2023 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input  logic [9:0] BallX, BallY, DrawX, DrawY, Ball_size,

                       input  logic        [9:0] Char1X, Char1Y, Char1S,
                       input  logic        [3:0] char1_r, char1_g, char1_b,

    // Character 2 inputs
                       input  logic        [9:0] Char2X, Char2Y, Char2S,
                       input  logic        [3:0] char2_r, char2_g, char2_b,

    // Background inputs
                       input  logic        [3:0] bg_r, bg_g, bg_b,
                       output logic [3:0]  Red, Green, Blue );
    
    logic ball_on;
	 
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*BallS, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))
       )

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 120 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
    int DistX, DistY, Size;
    assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;

    logic Char1_Active, Char2_Active;

    assign Char1_Active = (DrawX >= Char1X) && (DrawX < Char1X + Char1S) &&
                          (DrawY >= Char1Y) && (DrawY < Char1Y + Char1S);

    assign Char2_Active = (DrawX >= Char2X) && (DrawX < Char2X + Char2S) &&
                          (DrawY >= Char2Y) && (DrawY < Char2Y + Char2S);
  
    always_comb
    begin:Ball_on_proc
        if ( (DistX*DistX + DistY*DistY) <= (Size * Size) )
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
       
    always_comb begin: RGB_Display
        if (Char1_Active) begin
            Red   = char1_r;
            Green = char1_g;
            Blue  = char1_b;
        end else if (Char2_Active) begin
            Red   = char2_r;
            Green = char2_g;
            Blue  = char2_b;
        end else if (ball_on) begin
            Red   = 4'hf;
            Green = 4'h7;
            Blue  = 4'h0;
        end else begin
            Red   = bg_r;
            Green = bg_g;
            Blue  = bg_b;
        end
    end
    
endmodule
