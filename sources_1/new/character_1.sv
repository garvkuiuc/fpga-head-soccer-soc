module character_1 
( 
    input  logic        Reset, 
    input  logic        frame_clk,
    input  logic [31:0] keycode,

    output logic  [9:0] CharX, 
    output logic  [9:0] CharY, 
    output logic  [9:0] CharS 
);

    parameter [9:0] Char_X_Center = 200;
    parameter [9:0] Char_Y_Center = 240;
    parameter [9:0] Char_X_Min = 0;
    parameter [9:0] Char_X_Max = 639;
    parameter [9:0] Char_Y_Min = 0;
    parameter [9:0] Char_Y_Max = 400;
    parameter [9:0] CharSize    = 32;

    logic signed [10:0] Char_X_Motion, Char_Y_Motion;
    logic signed [10:0] Char_X_next, Char_Y_next;

    logic [7:0] first8  = keycode[31:24];
    logic [7:0] second8 = keycode[23:16];
    logic [7:0] third8  = keycode[15:8];
    logic [7:0] fourth8 = keycode[7:0];

    assign CharS = CharSize;

    always_ff @(posedge frame_clk) begin
        if (Reset) begin
            CharX <= Char_X_Center;
            CharY <= Char_Y_Center;
            Char_X_Motion <= 0;
            Char_Y_Motion <= 0;
        end 
        
        else begin
            // Default motion
            Char_X_Motion = 0;

            // Horizontal input
            if (first8 == 8'h04 || second8 == 8'h04 || third8 == 8'h04 || fourth8 == 8'h04)
                Char_X_Motion = -4;
            if (first8 == 8'h07 || second8 == 8'h07 || third8 == 8'h07 || fourth8 == 8'h07)
                Char_X_Motion = 4;

            // Jump
            if ((first8 == 8'h1A || second8 == 8'h1A || third8 == 8'h1A || fourth8 == 8'h1A) &&
                CharY == Char_Y_Max - CharS)
                Char_Y_Motion = -18;

            // Apply gravity
            Char_Y_Motion = Char_Y_Motion + 1;

            // Predict next
            Char_X_next = CharX + Char_X_Motion;
            Char_Y_next = CharY + Char_Y_Motion;

            // Horizontal clamp
            if (Char_X_next < 0)
                CharX <= 0;
            else if (Char_X_next > Char_X_Max - CharS)
                CharX <= Char_X_Max - CharS;
            else
                CharX <= Char_X_next;

            // Vertical clamp
            if (Char_Y_next < Char_Y_Min)
                CharY <= Char_Y_Min;
            else if (Char_Y_next > Char_Y_Max - CharS)
                CharY <= Char_Y_Max - CharS;
            else
                CharY <= Char_Y_next;
                
            if (Char_Y_next >= Char_Y_Max - CharS)
                Char_Y_Motion <= 0;
            
        end
    end
endmodule
