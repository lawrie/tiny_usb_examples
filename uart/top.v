module top (
  input  pin_clk,

  inout  pin_usbp,
  inout  pin_usbn,
  output pin_pu,

  output pin_led
);

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  ////////
  //////// generate 48 mhz clock
  ////////
  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  wire clk_48mhz;

  SB_PLL40_CORE #(
    .DIVR(4'b0000),
    .DIVF(7'b0101111),
    .DIVQ(3'b100),
    .FILTER_RANGE(3'b001),
    .FEEDBACK_PATH("SIMPLE"),
    .DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
    .FDA_FEEDBACK(4'b0000),
    .DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
    .FDA_RELATIVE(4'b0000),
    .SHIFTREG_DIV_MODE(2'b00),
    .PLLOUT_SELECT("GENCLK"),
    .ENABLE_ICEGATE(1'b0)
  ) usb_pll_inst (
    .REFERENCECLK(pin_clk),
    .PLLOUTCORE(clk_48mhz),
    .PLLOUTGLOBAL(),
    .EXTFEEDBACK(),
    .DYNAMICDELAY(),
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .LATCHINPUTVALUE(),
    .LOCK(),
    .SDI(),
    .SDO(),
    .SCLK()
  );

  reg [7:0] uart_di;
  wire [7:0] uart_do;
  reg uart_re, uart_we;
  wire uart_wait;

  // Generate reset signal
  reg [5:0] reset_cnt = 0;
  wire resetn = &reset_cnt;

  always @(posedge clk_48mhz) begin
    reset_cnt <= reset_cnt + !resetn;
  end

  // Create the text string
  reg [7:0] text [0:12];

  initial begin
  text[0]  <= "H";
  text[1]  <= "e";
  text[2]  <= "l";
  text[3]  <= "l";
  text[4]  <= "o";
  text[5]  <= " ";
  text[6]  <= "W";
  text[7]  <= "o";
  text[8]  <= "r";
  text[9]  <= "l";
  text[10] <= "d";
  text[11] <= "!";
  text[12] <= "\n";
  end

  // Send characters about every second
  reg [22:0] delay_count;
  reg [3:0] char_count;
  reg wait_for_send;

  always @(posedge clk_48mhz) begin
    delay_count <= delay_count + 1;
    if  (resetn && !wait_for_send) begin
      if (&delay_count) begin
        if (char_count == 12) char_count <= 0;
        else char_count <= char_count + 1;
        uart_di <= text[char_count];
        uart_we <= 1;
        wait_for_send <= 1;
      end
    end else if (!uart_wait) begin
      uart_we <= 0;
      wait_for_send <= 0;
    end
  end

  // usb uart
  usb_uart uart (
    .clk_48mhz  (clk_48mhz),
    .resetn      (resetn),

    .usb_p_tx(usb_p_tx),
    .usb_n_tx(usb_n_tx),
    .usb_p_rx(usb_p_rx),
    .usb_n_rx(usb_n_rx),
    .usb_tx_en(usb_tx_en),

    .uart_we  (uart_we),
    .uart_re  (uart_re),
    .uart_di  (uart_di),
    .uart_do  (uart_do),
    .uart_wait(uart_wait),

    .led(pin_led)
  );

  wire usb_p_tx;
  wire usb_n_tx;
  wire usb_p_rx;
  wire usb_n_rx;
  wire usb_tx_en;

  assign pin_pu = 1'b1;
  assign pin_usbp = usb_tx_en ? usb_p_tx : 1'bz;
  assign pin_usbn = usb_tx_en ? usb_n_tx : 1'bz;
  assign usb_p_rx = usb_tx_en ? 1'b1 : pin_usbp;
  assign usb_n_rx = usb_tx_en ? 1'b0 : pin_usbn;

endmodule
