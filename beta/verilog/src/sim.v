/* Copyright 2020 Chris Marc Dailey (cmd) <nitz@users.noreply.github.com> */
`default_nettype none

/*
 *  A small simulation test harness.
 */

module sim (
    input clk,
    output [31:0] InstructionAddress,
    output [31:0] InstructionData,
    output [31:0] DataAddress,
    output [31:0] DataRead,
    output [31:0] DataWrite,
    output WriteEnable
);
  reg [31:0] mainmem[65536];
  wire [31:0] InstructionAddress;
  wire [31:0] InstructionData;
  wire [31:0] DataAddress;
  reg [31:0] DataRead;
  wire [31:0] DataWrite;
  wire WriteEnable;
  wire ReadEnable;
  wire irq = 0;
  wire rst = 0;
  Beta test_beta (
      .clk(clk),
      .InstructionAddress(InstructionAddress),
      .InstructionData(InstructionData),
      .DataAddress(DataAddress),
      .DataRead(DataRead),
      .DataWrite(DataWrite),
      .WriteEnable(WriteEnable),
      .ReadEnable(ReadEnable),
      .irq(irq),
      .rst(rst)
  );
  initial begin  // load main memory with program initialy
    $readmemh("instructions.hex", mainmem);
  end
  // allow main memory access
  assign InstructionData = mainmem[(InstructionAddress>>2)];
  always @(posedge clk) begin
    if (WriteEnable) mainmem[(DataAddress>>2)] <= DataWrite;
    if (ReadEnable) DataRead <= mainmem[(DataAddress>>2)];
  end
endmodule
