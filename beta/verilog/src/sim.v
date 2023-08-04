/* Copyright 2020 Chris Marc Dailey (cmd) <nitz@users.noreply.github.com> */
`default_nettype none

/*
 *  A small simulation test harness.
 */

module sim (
    input clk,
    output [2:0] led_o,
    output [31:0] ReadPort1,
    output [31:0] ReadPort2
);
  /*
  top sim_top (
      clk,
      led_o
  );
  */
  reg [13:0] main_counter = 1;
  reg [1:0] tmp = 0;
  reg [4:0] WriteAddress = 0;
  reg [31:0] WritePort = 0;
  reg [4:0] PrevWriteAddress = 0;
  wire WriteEnable;
  wire [4:0] ReadAddress1;
  wire [4:0] ReadAddress2;
  wire rst;
  register_file test_register_file (
      clk,
      WriteAddress,
      WritePort,
      WriteEnable,
      ReadAddress1,
      ReadAddress2,
      rst,
      ReadPort1,
      ReadPort2
  );
  always @(posedge clk) begin
    main_counter <= main_counter + 1;
    if (main_counter == 0) begin
      tmp <= 1;
      rst <= 1;
    end else rst <= 0;
    PrevWriteAddress <= WriteAddress;
    if (tmp == 0) begin
      WriteAddress <= WriteAddress + 1;
    end
    if (WriteAddress == 31) begin
      tmp <= 1;
      WritePort <= WritePort + 1;
    end
    if (tmp !== 0) begin
      tmp <= tmp + 1;
    end
  end

  assign WriteEnable  = (tmp == 0) ? 1 : 0;
  assign ReadAddress1 = PrevWriteAddress;
  assign ReadAddress2 = WriteAddress;

endmodule
