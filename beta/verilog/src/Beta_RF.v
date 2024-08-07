`default_nettype none
// Interrupt Vectors
`define RESET 32'h0
`define ILLOP 32'h4
`define XADR 32'h8
// Instruction shorthands
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
    output [6:0] bypassAddr,
    output halt
);
  // basic signals
  reg [31:0] pc = 0;
  reg [31:0] ir = `NOP;
  wire [31:0] sxtConstant;
  wire ra2sel;
  wire asel;
  wire bsel;
  wire ra1Disable;
  wire ra2Disable;
  wire z;
  wire [5:0] opcode;

  assign opcode = ir[31:26];  // isolate opcode from instruction
  assign sxtConstant = $signed(ir[15:0]);  // Sign extend constant from instruction
  assign cRelativeA = pc + (sxtConstant << 2); // calculate relative address from sign extended constant
  assign ra2sel = (ir[31:26] == 6'b011001);  // determine where ra2 index comes from
  assign asel = (ir[31:26] == 6'b011111);  // determine whether a is being used
  assign bsel = !(ir[31:30] == 2'b10);  // determine whether b is being used

  assign ra1Disable = asel;  // disable ra1 if a is not being used
  assign ra2Disable = bsel && !(ra2sel);  // disable ra2 if b is not being used

  assign ra1 = ra1Disable ? 5'b11111 : ir[20:16];  // output first register address if enabled.
  assign ra2 = ra2Disable ? 5'b11111 : (ra2sel ? ir[25:21] : ir[15:11]); // output register 2 address if enabled

  assign a = asel ? cRelativeA : rd1;  // determine whether a is rd1 or Relative address
  assign b = bsel ? sxtConstant : rd2;  // determine whether b is rd2 or sign extended constant

  assign jt = rd1;  // rd1 is jump target
  assign d = rd2;  // rd2 is write data
  assign z = !(|rd1);  // check if rd1 is zero for branch
  assign bypassAddr = {
    (ir[31:26] == 6'b011011 || ir[31:26] == 6'b011101 || ir[31:26] == 6'b011110),
    ir[31],
    (ir[31:26] == 6'b011001) ? 5'b11111 : ir[25:21]
  };  // Register that will be written to for bypass logic

  always @(posedge clk) begin
    if (stall) begin  // stall logic
      pc <= pc;
      ir <= ir;
    end else begin  // pipeline logic
      pc <= pcin;
      case (irsrc)  // IRsrc logic
        0: ir <= irin;
        1: ir <= `BNE;
        default: ir <= `NOP;
      endcase
    end
  end

  assign pcout = pc;  // pipeline stuff
  assign irout = ir;
  assign halt  = !|ir;  // halt if instruction is 0

  always_comb begin  // determine pcsel based on opcode
    if (opcode[5]) begin
      if (!(opcode[3:1] == 3'b001 || opcode[2:0] == 3'b111)) begin
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
