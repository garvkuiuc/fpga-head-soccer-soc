module score_rom (
    input  logic [3:0] char,
    input  logic [2:0] row,
    output logic [7:0] pixels
);
    always_comb begin
        case (char)
            4'd0: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01101110;
                3'd3: pixels = 8'b01110110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase
            4'd1: case (row)
                3'd0: pixels = 8'b00011000;
                3'd1: pixels = 8'b00111000;
                3'd2: pixels = 8'b00011000;
                3'd3: pixels = 8'b00011000;
                3'd4: pixels = 8'b00011000;
                3'd5: pixels = 8'b00011000;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase
            4'd2: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b00000110;
                3'd3: pixels = 8'b00001100;
                3'd4: pixels = 8'b00110000;
                3'd5: pixels = 8'b01100000;
                3'd6: pixels = 8'b01111110;
                3'd7: pixels = 8'b00000000;
            endcase
            4'd3: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b00000110;
                3'd3: pixels = 8'b00011100;
                3'd4: pixels = 8'b00000110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase
            4'd4: case (row)
                3'd0: pixels = 8'b00001100;
                3'd1: pixels = 8'b00011100;
                3'd2: pixels = 8'b00111100;
                3'd3: pixels = 8'b01101100;
                3'd4: pixels = 8'b01111110;
                3'd5: pixels = 8'b00001100;
                3'd6: pixels = 8'b00001100;
                3'd7: pixels = 8'b00000000;
            endcase
            4'd5: case (row)
                3'd0: pixels = 8'b01111110;
                3'd1: pixels = 8'b01100000;
                3'd2: pixels = 8'b01111100;
                3'd3: pixels = 8'b00000110;
                3'd4: pixels = 8'b00000110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase
            4'd6: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100000;
                3'd2: pixels = 8'b01111100;
                3'd3: pixels = 8'b01100110;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase
            4'd7: case (row)
                3'd0: pixels = 8'b01111110;
                3'd1: pixels = 8'b00000110;
                3'd2: pixels = 8'b00001100;
                3'd3: pixels = 8'b00011000;
                3'd4: pixels = 8'b00110000;
                3'd5: pixels = 8'b00110000;
                3'd6: pixels = 8'b00110000;
                3'd7: pixels = 8'b00000000;
            endcase
            4'd8: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b00111100;
                3'd4: pixels = 8'b01100110;
                3'd5: pixels = 8'b01100110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase
            4'd9: case (row)
                3'd0: pixels = 8'b00111100;
                3'd1: pixels = 8'b01100110;
                3'd2: pixels = 8'b01100110;
                3'd3: pixels = 8'b00111110;
                3'd4: pixels = 8'b00000110;
                3'd5: pixels = 8'b00000110;
                3'd6: pixels = 8'b00111100;
                3'd7: pixels = 8'b00000000;
            endcase
            default: pixels = 8'b00000000;
        endcase
    end
endmodule
