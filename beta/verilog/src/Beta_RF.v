`default_nettype none
`define RESET 32'h0
`define ILLOP 32'h4
`define XADR 32'h8
`define NOP 32'b10000011111111111111111111111111
`define BNE 32'b01111011110111111111111111111111

module Beta_RF (
    input clk,
    input stall,
    input [1:0] irsrc,
    input [31:0] pcin,
    input [31:0] irin,
    output [4:0] ra1,
    output [4:0] ra2,
    input [31:0] rd1,
    input [31:0] rd2,
    output [31:0] pcout,
    output [31:0] irout,
    output [31:0] cRelativeA,
    output [31:0] a,
    output [31:0] b,
    output [31:0] d,
    output [31:0] jt,
    output [1:0] pcsel,
    output [6:0] bypassAddr
);
  reg [31:0] pc;
  reg [31:0] ir;
  wire [31:0] sxtConstant;
  wire ra2sel;
  wire asel;
  wire bsel;

  assign sxtConstant = $signed(InstructionData[15:0]);
  assign cRelativeA = pc + (sxtConstant << 2);
  assign ra2sel = (ir[31:26] == 6'b011001);
  assign asel = (ir[31:26] == 6'b011111);
  assign bsel = !(ir[31:30] == 2'b10);

  assign ra1 = ir[20:16];
  assign ra2 = ra2sel ? ir[25:21] : ir[15:11];

  assign a = asel ? cRelativeA : rd1;
  assign b = bsel ? sxtConstant : rd2;

  assign jt = rd1;
  assign d = rd2;
  assign z = !(|rd1);
  assign bypassAddr = {
    (ir[31:26] == 6'b011011 || ir[31:26] == 6'b011101 || ir[31:26] == 6'b011110),
    ir[31],
    (ir[31:26] == 6'b011001) ? 5'b11111 : ir[25:21]
  };

  always @(posedge clk) begin
    if (stall) begin
      pc <= pc;
      ir <= ir;
    end else begin
      pc <= pcin;
      case (irsrc)
        0: ir <= irin;
        1: ir <= `BNE;
        default: ir <= `NOP;
      endcase
    end
  end

  assign pcout = pc;
  assign irout = ir;

  always_comb begin
    if (opcode[5]) begin
      if (!(opcode[3:0] == 4'b0011 || opcode[2:0] == 3'b111)) begin
        pcsel = 0;
      end else pcsel = 3;
    end else begin
      case (opcode[2:0])
        3'b000:  pcsel = 0;
        3'b001:  pcsel = 0;
        3'b011:  pcsel = 2;
        3'b101:  pcsel = z;
        3'b110:  pcsel = !z;
        3'b111:  pcsel = 0;
        default: pcsel = 3;
      endcase
    end
  end

endmodule
