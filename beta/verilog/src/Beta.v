`default_nettype none
`define RESET 32'h0
`define ILLOP 32'h4
`define XADR 32'h8

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
  //start
  reg halt = 0;
  reg register_rst = 0;
  reg [31:0] pc = 0;
  reg irq_reg = 0;
  wire [31:0] nextpc;
  wire [31:0] crelativea;
  wire [31:0] sxtConstant;
  wire [4:0] wa;
  wire [31:0] wd;
  wire werf;
  wire [4:0] ra1;
  wire [4:0] ra2;
  wire [31:0] rd1;
  wire [31:0] rd2;
  wire [3:0] alufn;
  wire [31:0] a;
  wire [31:0] b;
  wire [31:0] aluresult;
  wire z;
  wire bsel;
  wire asel;
  wire [2:0] pcsel;
  wire ra2sel;
  wire wasel;
  wire [1:0] wdsel;
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
  Beta_ALU alu (
      .clk(clk),
      .AluFn(alufn),
      .InA(a),
      .InB(b),
      .Result(aluresult)
  );
  Control_logic control_logic (
      .opcode(InstructionData[31:26]),
      .irq(irq_reg),
      .z(z),
      .alufn(alufn),
      .werf(werf),
      .bsel(bsel),
      .asel(asel),
      .moe(ReadEnable),
      .mwr(WriteEnable),
      .pcsel(pcsel),
      .ra2sel(ra2sel),
      .wasel(wasel),
      .wdsel(wdsel)
  );
  assign nextpc = pc + 4;
  assign crelativea = nextpc + (sxtConstant << 2);
  assign sxtConstant = $signed(InstructionData[15:0]);
  assign InstructionAddress = pc;
  assign z = !(|rd1);
  assign wa = wasel ? (5'b11110) : InstructionData[25:21];
  assign ra1 = InstructionData[20:16];
  assign ra2 = ra2sel ? InstructionData[25:21] : InstructionData[15:11];
  assign a = asel ? crelativea : rd1;
  assign b = bsel ? sxtConstant : rd2;
  assign DataWrite = rd2;
  assign DataAddress = aluresult;
  always @(posedge clk) begin
    irq_reg <= irq;
    if (irq) halt <= 0;
    if ((InstructionData == 0) & !irq) halt <= 1;
    if (rst) begin
      pc <= `RESET;
    end else begin
      if (halt) begin
        pc <= pc;
      end else begin
        case (pcsel)
          default: pc <= `ILLOP;
          0: pc <= nextpc;
          1: pc <= crelativea;
          2: pc <= rd1;
          3: pc <= `ILLOP;
          4: pc <= `XADR;
        endcase
      end
    end
  end
  always @(*) begin
    case (wdsel)
      0: wd = nextpc;
      1: wd = aluresult;
      2: wd = DataRead;
      default: wd = 32'hdeadbeef;
    endcase
  end
endmodule
