`default_nettype none
`define RESET 32'h0
`define ILLOP 32'h4
`define XADR 32'h8
`define NOP 32'b10000011111111111111111111111111
`define BNE 32'b01111011110111111111111111111111



module Beta_ALU_stage (
    input clk,
    input [1:0] irsrc,
    input [31:0] pcin,
    input [31:0] irin,
    input [31:0] ain,
    input [31:0] bin,
    input [31:0] din,
    output [31:0] yout,
    output [31:0] pcout,
    output [31:0] irout,
    output [31:0] dout
);

  reg  [31:0] a = 0;
  reg  [31:0] b = 0;
  reg  [31:0] d = 0;
  reg  [31:0] pc = 0;
  reg  [31:0] ir = `NOP;
  wire [ 3:0] AluFn;

  always_comb begin
    if (ir[31:30] == 2'b01) begin
      AluFn = {(ir[28:26] == 3'b111), 3'b000};
    end else begin
      AluFn = ir[29:26];
    end
  end

  Beta_ALU ALU (
      .clk(clk),
      .AluFn(AluFn),
      .InA(a),
      .InB(b),
      .Result(yout)
  );

  assign pcout = pc;
  assign irout = ir;
  assign dout  = d;

  always @(posedge clk) begin
    pc <= pcin;
    a  <= ain;
    b  <= bin;
    d  <= din;
    case (irsrc)
      0: ir <= irin;
      1: ir <= `BNE;
      default: ir <= `NOP;
    endcase
  end






endmodule
