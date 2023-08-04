`default_nettype none

/*
 *  Blink a LED on the OrangeCrab using verilog
 */

module top (
    input clk_i,
    output [2:0] led_o
);
  // Create a 27 bit register
  reg [26:0] counter = 0;

  // Every positive edge increment register by 1
  always @(posedge clk_i) begin
    counter <= counter + 1;
  end

  // Output inverted values of counter onto LEDs
  assign led_o[0] = ~counter[24];
  assign led_o[1] = ~counter[25];
  assign led_o[2] = 1;


endmodule
