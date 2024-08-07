`default_nettype none

module Beta (
    input clk,
    output [31:0] InstructionAddress,
    input [31:0] InstructionData,
    output [31:0] DataAddress,
    input [31:0] DataRead,
    output [31:0] DataWrite,
    output WriteEnable,
    output ReadEnable,
    input irq,
    input rst
);
  // initialize mmu
  Beta_MMU MMU ();
  // initialize Cpu and connect to signals
  Beta_core mainCpu (
      .clk(clk),
      .InstructionAddress(InstructionAddress),
      .InstructionData(InstructionData),
      .instructionReady(1),
      .iMemfault(0),
      .DataAddress(DataAddress),
      .DataRead(DataRead),
      .dataReady(1),
      .dMemfault(0),
      .DataWrite(DataWrite),
      .WriteEnable(WriteEnable),
      .ReadEnable(ReadEnable),
      .irq(irq),
      .rst(rst)
  );
  //start

endmodule
