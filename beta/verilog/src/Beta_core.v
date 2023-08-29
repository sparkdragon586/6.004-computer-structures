`default_nettype none
`define RESET 32'h0
`define ILLOP 32'h4
`define XADR 32'h8

module Beta_core (
    input clk,
    output [31:0] InstructionAddress,
    input [31:0] InstructionData,
    input instructionReady,
    output [31:0] DataAddress,
    input [31:0] DataRead,
    input dataReady,
    output [31:0] DataWrite,
    output WriteEnable,
    output ReadEnable,
    input irq,
    input rst
);
  //start

  wire [1:0] irsrc[4];
  wire [31:0] pcPipe[5];
  wire [31:0] irPipe[5];
  wire [31:0] rd1Bypass;
  wire [31:0] rd2Bypass;


  register_file registers (
      .clk(clk),
      .WriteAddress(wa),
      .WritePort(wd),
      .WriteEnable(werf),
      .ReadAddress1(ra1),
      .ReadAddress2(ra2),
      .rst(register_rst),
      .ReadPort1(rd1),
      .ReadPort2(rd2)
  );
  Beta_IF IF (
      .clk(clk),
      .stall(stall),
      .cRelativeA(cRelativeA),
      .jt(jt),
      .PCSEL(PCSEL),
      .pcout(pcPipe[0]),
      .iAddress(InstructionAddress),
      .iData(InstructionData),
      .irout(irPipe[0])
  );
  Beta_RF RF (
      .clk(clk),
      .stall(stall),
      .irsrc(irsrc[0]),
      .pcin(pcPipe[0]),
      .irin(irPipe[0]),
      .ra1(ra1),
      .ra2(ra2),
      .rd1(rd1Bypass),
      .rd2(rd2Bypass),
      .pcout(pcPipe[1]),
      .irout(irPipe[1]),
      .cRelativeA(cRelativeA),
      .a(a),
      .b(b),
      .d(dPipe[0]),
      .jt(jt),
      .pcsel(pcsel)
  );


endmodule
