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
  reg [31:0] memWaitAddr;
  reg [6:0] accessPipeline[3];
  wire [2:0] bypassControl[2];
  wire [1:0] irsrc[4];
  wire [31:0] pcPipe[5];
  wire [31:0] irPipe[5];
  wire [31:0] rd1Bypass;
  wire [31:0] rd2Bypass;
  wire [6:0] bypassAddr;
  wire [31:0] ALUbypass;
  wire [31:0] MEMbypass;
  wire [31:0] WBbypass;
  wire [31:0] a;
  wire [31:0] b;
  wire [31:0] yPipe[2];

  always @(posedge clk) begin
    case (irsrc[1])
      default: accessPipeline[0] <= bypassAddr;
      1: accessPipeline[0] <= 6'b101110;
      2: accessPipeline[0] <= 6'b111111;
    endcase
    case (irsrc[2])
      default: accessPipeline[1] <= accessPipeline[0];
      1: accessPipeline[1] <= 6'b101110;
      2: accessPipeline[1] <= 6'b111111;
    endcase
    case (irsrc[3])
      default: accessPipeline[2] <= accessPipeline[1];
      1: accessPipeline[2] <= 6'b101110;
      2: accessPipeline[2] <= 6'b111111;
    endcase
  end

  Beta_bypass bypass1 (
      .RFAin(ra1),
      .RFDin(rd1),
      .ALUin(ALUbypass),
      .MEMin(MEMbypass),
      .WBin (WBbypass),
      .aP0  (accessPipeline[0]),
      .aP1  (accessPipeline[1]),
      .aP2  (accessPipeline[2]),
      .Dout (rd1Bypass),
      .stall(stall1)
  );

  Beta_bypass bypass2 (
      .RFAin(ra2),
      .RFDin(rd2),
      .ALUin(ALUbypass),
      .MEMin(MEMbypass),
      .WBin (WBbypass),
      .aP0  (accessPipeline[0]),
      .aP1  (accessPipeline[1]),
      .aP2  (accessPipeline[2]),
      .Dout (rd2Bypass),
      .stall(stall2)
  );


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
      .irout(irPipe[0]),
      .memWaitAddr(memWaitAddr)
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
      .pcsel(pcsel),
      .bypassAddr(bypassAddr)
  );
  Beta_ALU_stage ALU (
      .clk  (clk),
      .irsrc(irsrc[1]),
      .pcin (pcPipe[1]),
      .irin (irPipe[1]),
      .ain  (a),
      .bin  (b),
      .din  (dPipe[0]),
      .yout (yPipe[0]),
      .pcout(pcPipe[2]),
      .irout(irPipe[2]),
      .dout (dPipe[1])
  );
  Beta_MEM MEM (
      .clk(clk),
      .irsrc(irsrc[2]),
      .pcin(pcPipe[2]),
      .irin(irPipe[2]),
      .yin(yPipe[0]),
      .din(dPipe[1]),
      .wd(DataWrite),
      .addr(DataAddress),
      .mwr(),
      .moe(),
      .pcout(pcPipe[3]),
      .irout(irPipe[3]),
      .yout(yPipe[1])
  );
  Beta_WB WB (
      .clk(clk),
      .irsrc(irPipe[3]),
      .pcin(pcPipe[3]),
      .irin(irPipe[3]),
      .yin(yPipe[1]),
      .rd(DataRead),
      .memwait(),
      .wa(WriteAddress),
      .wd(WritePort),
      .WERF(WriteEnable)
  );

endmodule
