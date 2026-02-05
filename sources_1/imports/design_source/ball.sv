//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf     03-01-2006                           --
//                                  03-12-2007                           --
//    Translated by Joe Meng        07-07-2013                           --
//    Modified by Zuofu Cheng       08-19-2023                           --
//    Modified by Satvik Yellanki   12-17-2023                           --
//    Fall 2024 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI Lab                                --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


//module  ball 
//( 
//    input  logic        Reset, 
//    input  logic        frame_clk,
//    input  logic [7:0]  keycode,

//    output logic [9:0]  BallX, 
//    output logic [9:0]  BallY, 
//    output logic [9:0]  BallS 
//);
    

	 
//    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
//    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
//    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
//    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
//    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
//    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
//    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
//    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

//    logic [9:0] Ball_X_Motion;
//    logic [9:0] Ball_X_Motion_next;
//    logic [9:0] Ball_Y_Motion;
//    logic [9:0] Ball_Y_Motion_next;

//    logic [9:0] Ball_X_next;
//    logic [9:0] Ball_Y_next;

//    always_comb begin
//        Ball_Y_Motion_next = Ball_Y_Motion; // set default motion to be same as prev clock cycle 
//        Ball_X_Motion_next = Ball_X_Motion;

//        //modify to control ball motion with the keycode
        
        
//        case(keycode)
        
//        8'h1A : begin
//            Ball_Y_Motion_next = -10'd1;
//            Ball_X_Motion_next = 0;
//        end
        
//        8'h16: begin
//            Ball_Y_Motion_next = 10'd1;
//            Ball_X_Motion_next = 0;
//        end
            
//        8'h07: begin
//            Ball_X_Motion_next = 10'd1;
//            Ball_Y_Motion_next = 0;
//        end
            
//        8'h04: begin
//            Ball_X_Motion_next = -10'd1; 
//            Ball_Y_Motion_next = 0;
//        end
        
//        endcase
        
//        if ( (BallY + BallS) >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
//        begin
//            Ball_Y_Motion_next = (~ (Ball_Y_Step) + 1'b1);  // set to -1 via 2's complement.
//        end
//        else if ( (BallY - BallS) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
//        begin
//            Ball_Y_Motion_next = Ball_Y_Step;
//        end  
//       //fill in the rest of the motion equations here to bounce left and right

//        if ( (BallX + BallS) >= Ball_X_Max )  // Ball is at the bottom edge, BOUNCE!
//        begin
//            Ball_X_Motion_next = (~ (Ball_X_Step) + 1'b1);  // set to -1 via 2's complement.
//        end
//        else if ( (BallX - BallS) <= Ball_X_Min )  // Ball is at the top edge, BOUNCE!
//        begin
//            Ball_X_Motion_next = Ball_X_Step;
//        end
        
//        else begin
        
//            Ball_Y_Motion_next = Ball_Y_Motion_next; // set default motion to be same as prev clock cycle 
//            Ball_X_Motion_next = Ball_X_Motion_next;
//        end
//    end

//    assign BallS = 16;  // default ball size
//    assign Ball_X_next = (BallX + Ball_X_Motion_next);
//    assign Ball_Y_next = (BallY + Ball_Y_Motion_next);
   
//    always_ff @(posedge frame_clk) //make sure the frame clock is instantiated correctly
//    begin: Move_Ball
//        if (Reset)
//        begin 
//            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
//			Ball_X_Motion <= 10'd1; //Ball_X_Step;
            
//			BallY <= Ball_Y_Center;
//			BallX <= Ball_X_Center;
//        end
//        else 
//        begin 

//			Ball_Y_Motion <= Ball_Y_Motion_next; 
//			Ball_X_Motion <= Ball_X_Motion_next; 

//            BallY <= Ball_Y_next;  // Update ball position
//            BallX <= Ball_X_next;
			
//		end  
//    end




module ball 
( 
    input  logic        Reset, 
    input  logic        frame_clk,

    input  logic [9:0]  Char1X,
    input  logic [9:0]  Char1Y,
    input  logic [9:0]  Char1S,
    input  logic [9:0]  Char2X,
    input  logic [9:0]  Char2Y,
    input  logic [9:0]  Char2S,

    output logic [9:0]  BallX, 
    output logic [9:0]  BallY, 
    output logic [9:0]  BallS 
);

    // Parameters
    parameter [9:0] Ball_X_Center = 320;
    parameter [9:0] Ball_Y_Center = 240;
    parameter [9:0] Ball_X_Min = 0;
    parameter [9:0] Ball_X_Max = 639;
    parameter [9:0] Ball_Y_Min = 0;
    parameter [9:0] Ball_Y_Max = 479;
    parameter [9:0] Ball_Size    = 16;  // Increased for visibility

    parameter logic signed [15:0] GRAVITY = 16'sd4;

    // Internal fixed-point state
    logic signed [15:0] Ball_X_fp, Ball_Y_fp;
    logic signed [15:0] Ball_VX_fp, Ball_VY_fp;

    assign BallS = Ball_Size;

    always_ff @(posedge frame_clk) begin
        if (Reset) begin
            Ball_X_fp  <= Ball_X_Center <<< 4;
            Ball_Y_fp  <= Ball_Y_Center <<< 4;
            Ball_VX_fp <= -16'sd8;
            Ball_VY_fp <= 16'sd0;
            BallX      <= Ball_X_Center;   // ? initialize your outputs
            BallY      <= Ball_Y_Center;
        end else begin
            // Gravity
            Ball_VY_fp <= Ball_VY_fp + GRAVITY;

            // Update position
            Ball_X_fp <= Ball_X_fp + Ball_VX_fp;
            Ball_Y_fp <= Ball_Y_fp + Ball_VY_fp;

            // Integer output values (registered)
            BallX <= Ball_X_fp[15:4];
            BallY <= Ball_Y_fp[15:4];

            // Collision with Character 1
            if ((BallX + Ball_Size > Char1X) && (BallX < Char1X + Char1S) &&
                (BallY + Ball_Size > Char1Y) && (BallY < Char1Y + Char1S)) begin
                Ball_VX_fp <= (BallX < Char1X) ? -16'sd32 : 16'sd32;
                Ball_VY_fp <= (BallY + Ball_Size / 2 < Char1Y + Char1S / 2) ? -16'sd24 : 16'sd12;
            end

            // Collision with Character 2
            if ((BallX + Ball_Size > Char2X) && (BallX < Char2X + Char2S) &&
                (BallY + Ball_Size > Char2Y) && (BallY < Char2Y + Char2S)) begin
                Ball_VX_fp <= (BallX < Char2X) ? -16'sd32 : 16'sd32;
                Ball_VY_fp <= (BallY + Ball_Size / 2 < Char2Y + Char2S / 2) ? -16'sd24 : 16'sd12;
            end

            // Bounce on floor
            if (BallY >= Ball_Y_Max - Ball_Size) begin
                Ball_Y_fp  <= (Ball_Y_Max - Ball_Size) <<< 4;
                Ball_VY_fp <= -Ball_VY_fp >>> 1;
            end

            // Bounce on ceiling
            if (BallY <= Ball_Y_Min) begin
                Ball_Y_fp  <= Ball_Y_Min <<< 4;
                Ball_VY_fp <= -Ball_VY_fp >>> 1;
            end

            // Bounce on walls
            if (BallX <= Ball_X_Min) begin
                Ball_X_fp  <= Ball_X_Min <<< 4;
                Ball_VX_fp <= -Ball_VX_fp >>> 1;
            end else if (BallX >= Ball_X_Max - Ball_Size) begin
                Ball_X_fp  <= (Ball_X_Max - Ball_Size) <<< 4;
                Ball_VX_fp <= -Ball_VX_fp >>> 1;
            end
        end
    end

endmodule


    
      
//endmodule