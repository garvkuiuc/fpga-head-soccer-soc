//-------------------------------------------------------------------------
//    mb_usb_hdmi_top.sv                                                 --
//    Zuofu Cheng                                                        --
//    2-29-24                                                            --
//                                                                       --
//    Spring 2024 Distribution                                           --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

module mb_usb_hdmi_top(
    input  logic        Clk,
    input  logic        reset_rtl_0,
    
    // USB signals
    input  logic [0:0]  gpio_usb_int_tri_i,
    output logic        gpio_usb_rst_tri_o,
    input  logic        usb_spi_miso,
    output logic        usb_spi_mosi,
    output logic        usb_spi_sclk,
    output logic        usb_spi_ss,
    
    // UART
    input  logic        uart_rtl_0_rxd,
    output logic        uart_rtl_0_txd,
    
    // HDMI
    output logic        hdmi_tmds_clk_n,
    output logic        hdmi_tmds_clk_p,
    output logic [2:0]  hdmi_tmds_data_n,
    output logic [2:0]  hdmi_tmds_data_p,
        
    // HEX displays
    output logic [7:0]  hex_segA,
    output logic [3:0]  hex_gridA,
    output logic [7:0]  hex_segB,
    output logic [3:0]  hex_gridB
);

    //-------------------------------------------------------------------------
    // Internal Signals
    //-------------------------------------------------------------------------
    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic        clk_25MHz, clk_125MHz, clk_100MHz, locked;
    logic [9:0]  drawX, drawY, ballxsig, ballysig, ballsizesig;
    logic        hsync, vsync, vde;
    logic [3:0]  red, green, blue;
    logic        reset_ah;
    logic [9:0]  char1_x, char1_y, char2_x, char2_y;
    logic [9:0]  Char1S, Char2S;
    logic        goal_p1, goal_p2;
    logic [3:0]  score_p1, score_p2;
    logic        reset_goal;

    assign reset_ah = reset_rtl_0;

    //-------------------------------------------------------------------------
    // USB Keycode HEX Displays
    //-------------------------------------------------------------------------
    hex_driver HexA (
        .clk     (Clk),
        .reset   (reset_ah),
        .in      ({ keycode0_gpio[31:28],
                    keycode0_gpio[27:24],
                    keycode0_gpio[23:20],
                    keycode0_gpio[19:16] }),
        .hex_seg (hex_segA),
        .hex_grid(hex_gridA)
    );

    hex_driver HexB (
        .clk     (Clk),
        .reset   (reset_ah),
        .in      ({ keycode0_gpio[15:12],
                    keycode0_gpio[11: 8],
                    keycode0_gpio[ 7: 4],
                    keycode0_gpio[ 3: 0] }),
        .hex_seg (hex_segB),
        .hex_grid(hex_gridB)
    );

    //-------------------------------------------------------------------------
    // MicroBlaze + USB
    //-------------------------------------------------------------------------
    mb_block mb_block_i (
        .clk_100MHz        (Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0       (~reset_ah),
        .uart_rtl_0_rxd    (uart_rtl_0_rxd),
        .uart_rtl_0_txd    (uart_rtl_0_txd),
        .usb_spi_miso      (usb_spi_miso),
        .usb_spi_mosi      (usb_spi_mosi),
        .usb_spi_sclk      (usb_spi_sclk),
        .usb_spi_ss        (usb_spi_ss)
    );

    //-------------------------------------------------------------------------
    // Clock Wizard
    //-------------------------------------------------------------------------
    clk_wiz_0 clk_wiz (
        .clk_out1   (clk_25MHz),
        .clk_out2   (clk_125MHz),
        .reset      (reset_ah),
        .locked     (locked),
        .clk_in1    (Clk)
    );

    //-------------------------------------------------------------------------
    // VGA Timing Controller
    //-------------------------------------------------------------------------
    vga_controller vga (
        .pixel_clk    (clk_25MHz),
        .reset        (reset_ah),
        .hs           (hsync),
        .vs           (vsync),
        .active_nblank(vde),
        .drawX        (drawX),
        .drawY        (drawY)
    );

    //-------------------------------------------------------------------------
    // Ball Logic
    //-------------------------------------------------------------------------
    ball_control ball_inst (
        .Reset     (reset_ah || reset_goal),
        .frame_clk (vsync),
        .Char1X    (char1_x),
        .Char1Y    (char1_y),
        .Char1S    (Char1S),
        .Char2X    (char2_x),
        .Char2Y    (char2_y),
        .Char2S    (Char2S),
        .BallX     (ballxsig),
        .BallY     (ballysig),
        .BallS     (ballsizesig)
    );

    //-------------------------------------------------------------------------
    // Goal Detection
    //-------------------------------------------------------------------------
    goal_detector goal_det (
        .clk    (vsync),
        .Reset  (reset_ah),
        .BallX  (ballxsig),
        .BallY  (ballysig),
        .BallS  (ballsizesig),
        .goal_p1(goal_p1),
        .goal_p2(goal_p2),
        .reset  (reset_goal)
    );

    //-------------------------------------------------------------------------
    // Scoreboard Logic
    //-------------------------------------------------------------------------
    scoreboard sb (
        .clk         (vsync),
        .reset       (reset_ah),
        .goal_player1(goal_p1),
        .goal_player2(goal_p2),
        .score_p1    (score_p1),
        .score_p2    (score_p2)
    );

    //-------------------------------------------------------------------------
    // Background + Sprites + Score overlay
    //-------------------------------------------------------------------------
    NewBG_example NewBG_example (
        .vga_clk (clk_25MHz),
        .DrawX   (drawX),
        .DrawY   (drawY),
        .blank   (vde),
        .Char1X  (char1_x),
        .Char1Y  (char1_y),
        .Char1S  (Char1S),
        .Char2X  (char2_x),
        .Char2Y  (char2_y),
        .Char2S  (Char2S),
        .BallX   (ballxsig),
        .BallY   (ballysig),
        .BallS   (ballsizesig),
        .score_p1(score_p1),
        .score_p2(score_p2),
        .red     (red),
        .green   (green),
        .blue    (blue)
    );

    //-------------------------------------------------------------------------
    // Characters
    //-------------------------------------------------------------------------
    character_1 player1 (
        .Reset     (reset_ah || reset_goal),
        .frame_clk (vsync),
        .keycode   (keycode0_gpio),
        .CharX     (char1_x),
        .CharY     (char1_y),
        .CharS     (Char1S)
    );

    character_2 player2 (
        .Reset     (reset_ah || reset_goal),
        .frame_clk (vsync),
        .keycode   (keycode0_gpio),
        .CharX     (char2_x),
        .CharY     (char2_y),
        .CharS     (Char2S)
    );

    //-------------------------------------------------------------------------
    // HDMI Output
    //-------------------------------------------------------------------------
    hdmi_tx_0 vga_to_hdmi (
        .pix_clk       (clk_25MHz),
        .pix_clkx5     (clk_125MHz),
        .pix_clk_locked(locked),
        .rst           (reset_ah),
        .red           (red),
        .green         (green),
        .blue          (blue),
        .hsync         (hsync),
        .vsync         (vsync),
        .vde           (vde),
        .aux0_din      (4'b0),
        .aux1_din      (4'b0),
        .aux2_din      (4'b0),
        .ade           (1'b0),
        .TMDS_CLK_P    (hdmi_tmds_clk_p),
        .TMDS_CLK_N    (hdmi_tmds_clk_n),
        .TMDS_DATA_P   (hdmi_tmds_data_p),
        .TMDS_DATA_N   (hdmi_tmds_data_n)
    );
    
    

endmodule
