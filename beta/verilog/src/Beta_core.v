`default_nettype none
`define RESET 32'h0
`define ILLOP 32'h4
`define XADR 32'h8

module Beta_core (
    input clk,
    output [31:0] InstructionAddress,
    input [31:0] InstructionData,
    input instructionReady,
    input iMemfault,
    output [31:0] DataAddress,
    input [31:0] DataRead,
    input dataReady,
    input dMemfault,
    output [31:0] DataWrite,
    output WriteEnable,
    output ReadEnable,
    input irq,
    input rst
);
  //start

  // interconnect signals
  reg halt = 0;
  wire halts;
  reg [31:0] memWaitAddr;
  reg [6:0] accessPipeline[3];
  wire interruptEnable = 1;
  wire [2:0] bypassControl[2];
  wire [1:0] irsrc[4];
  wire irsrcCtrl[3];
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
  wire [31:0] dPipe[2];
  wire [2:0] PCSEL;
  wire [2:0] pcselRF;
  wire ALUException = 0;
  wire mwr;
  wire stall1;
  wire stall2;
  wire stall;
  wire interrupt;
  wire [4:0] wa;
  wire [31:0] wd;
  wire [4:0] ra1;
  wire [4:0] ra2;
  wire [31:0] rd1;
  wire [31:0] rd2;
  wire werf;
  wire register_rst = rst;
  wire [31:0] cRelativeA;
  wire [31:0] jt;

  // initialize access pipeline for RF bypass to hardwired register
  initial accessPipeline[0] = 7'b1111111;
  initial accessPipeline[1] = 7'b1111111;
  initial accessPipeline[2] = 7'b1111111;

  always @(posedge clk) begin  // correct access pipeline for exceptions
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

  always @(posedge clk) begin  // Carry halt through and enable halt if it is raised
    halt <= halt || halts;
  end

  assign stall = (stall1 || stall2 || !instructionReady || halt); // Stall if either register stalls, the instruction is not ready or halt is raised
  assign interrupt = irq && interruptEnable; // cause interrupt if an irq is raised and interrupts are enabled
  assign ALUbypass = accessPipeline[0][6] ? pcPipe[2] : yPipe[0]; // determine whether bypasses come from results or PC
  assign MEMbypass = accessPipeline[1][6] ? pcPipe[3] : yPipe[1];
  assign WBbypass = wd;

  always_comb begin
    if (interrupt) begin  // if interrupt is raised jump to interrupt handeler
      PCSEL = 4;
    end else begin
      case ({
        dataReady, (pcselRF != 0)
      })
        default: PCSEL = 3'h0;
        0: PCSEL = 5;
        1: PCSEL = 5;
        3: PCSEL = pcselRF;
      endcase
    end

    if (iMemfault) begin  // currently unused
      irsrc[0] = (irsrcCtrl[0] && !interrupt) ? 2'd2 : 2'd1;
    end else begin  // IRSRC logic
      irsrc[0] = interrupt ? 2'd1 : (irsrcCtrl[0] ? 2'd2 : 2'd0);
    end
    if (pcselRF != 0) begin
      irsrcCtrl[0] = 1;
      irsrc[1] = irsrcCtrl[1] ? 2'd2 : ((pcselRF == 3 || pcselRF == 4) ? 2'd1 : 2'd0);
    end else begin
      irsrcCtrl[0] = irsrcCtrl[1];
      irsrc[1] = (irsrcCtrl[1] || stall) ? 2'd2 : 2'd0;
    end
    if (ALUException) begin
      irsrcCtrl[1] = 1;
      irsrc[2] = irsrcCtrl[2] ? 2'd2 : 2'd1;
    end else begin
      irsrcCtrl[1] = irsrcCtrl[2];
      irsrc[2] = irsrcCtrl[2] ? 2'd2 : 2'd0;
    end
    if (dataReady) begin
      if (dMemfault) begin
        irsrcCtrl[2] = 1;
        irsrc[3] = irsrcCtrl[3] ? 2'd2 : 2'd1;
      end else begin
        irsrcCtrl[2] = 0;
        irsrc[3] = 2'd0;
      end
      WriteEnable = mwr;
    end else begin
      WriteEnable = 0;
      irsrc[3] = 2'd2;
      irsrcCtrl[2] = 1;
    end
  end

  // instantiate pipeline and connect it
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
      .pcOut(pcPipe[0]),
      .iAddress(InstructionAddress),
      .iData(InstructionData),
      .irout(irPipe[0]),
      .memWaitAddr(memWaitAddr)
  );
  Beta_RF RF (
      .clk(clk),
      .halt(halts),
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
      .pcsel(pcselRF),
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
      .mwr(mwr),
      .moe(ReadEnable),
      .pcout(pcPipe[3]),
      .irout(irPipe[3]),
      .yout(yPipe[1])
  );
  Beta_WB WB (
      .clk(clk),
      .irsrc(irsrc[3]),
      .pcin(pcPipe[3]),
      .irin(irPipe[3]),
      .yin(yPipe[1]),
      .rd(DataRead),
      .memwait(!dataReady),
      .wa(wa),
      .wd(wd),
      .WERF(werf)
  );

endmodule
