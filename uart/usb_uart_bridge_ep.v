module usb_uart_bridge_ep (
  input clk,
  input reset,


  ////////////////////
  // out endpoint interface 
  ////////////////////
  output out_ep_req,
  input out_ep_grant,
  input out_ep_data_avail,
  input out_ep_setup,
  output out_ep_data_get,
  input [7:0] out_ep_data,
  output out_ep_stall,
  input out_ep_acked,


  ////////////////////
  // in endpoint interface 
  ////////////////////
  output reg in_ep_req,
  input in_ep_grant,
  input in_ep_data_free,
  output in_ep_data_put,
  output [7:0] in_ep_data,
  output reg in_ep_data_done = 0,
  output in_ep_stall,
  input in_ep_acked,

  // uart interface
  input uart_we,
  input uart_re,
  input [7:0] uart_di,
  output [7:0] uart_do,
  output reg uart_wait = 0,

  output reg led

);

  assign out_ep_stall = 1'b0;
  assign in_ep_stall = 1'b0;

  assign out_ep_req = 0;

  assign out_ep_data_get = 0;

  assign uart_do = 0;

  //assign in_ep_data = 8'd72;
  assign in_ep_data = uart_di;

  reg [2:0] state = 0;
  reg [1:0] delay_counter = 0;

  always @(posedge clk) begin
    in_ep_data_put <= 0;
    in_ep_data_done <= 0;
    case (state) 
    0: begin
      if (uart_we) begin
        led <= 1;
        state <= 1;
        uart_wait <= 1;
      end
    end
    1: begin
      if (in_ep_data_free) begin
        in_ep_req <= 1;
        state <= 2;
      end
    end
    2: begin
      if (in_ep_data_free && in_ep_grant) begin
        in_ep_data_put <= 1;
        state <= 3;
      end
    end
    3: begin
      in_ep_data_done <= 1;
      in_ep_req <= 0;
      state <= 4;
      delay_counter <= 0;
    end
    4: begin
      if (&delay_counter) begin
        uart_wait <= 0;
        state <= 0;
        led <= 0;
      end else delay_counter <= delay_counter + 1;
    end
    endcase
  end
endmodule
