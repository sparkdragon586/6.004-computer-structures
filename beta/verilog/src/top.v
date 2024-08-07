`default_nettype none

// instantiate cpu and connect to basic signals. currently does not do
// anything

module top (
    input clk,
    output [31:0] InstructionAddress,
    input [31:0] InstructionData,
    output [31:0] DataAddress,
    output [31:0] WriteData,
    input [31:0] ReadData,
    output oe,
    output we,
    input irq,
    input rst
);
  Beta test (
      .clk(clk),
      .InstructionAddress(InstructionAddress),
      .InstructionData(InstructionData),
      .DataAddress(DataAddress),
      .DataRead(ReadData),
      .DataWrite(WriteData),
      .WriteEnable(we),
      .ReadEnable(oe),
      .irq(irq),
      .rst(rst)
  );

endmodule
