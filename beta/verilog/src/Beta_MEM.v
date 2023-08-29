`default_nettype none
`define NOP 32'b10000011111111111111111111111111
`define BNE 32'b01111011110111111111111111111111

module Beta_MEM (
    input clk,
    input [1:0] irsrc,
    input [31:0] pcin,
    input [31:0] irin,
    input [31:0] yin,
    input [31:0] din,
    output [31:0] wd,
    output [31:0] addr,
    output mwr,
    output moe,
    output [31:0] pcout,
    output [31:0] irout,
    output [31:0] yout
);

  reg [31:0] pc;
  reg [31:0] ir;
  reg [31:0] y;
  reg [31:0] d;

  assign addr = y;
  assign yout = y;
  assign pcout = pc;
  assign irout = ir;
  assign wd = d;
  assign mwr = (ir[31:26] == 5'b011001);
  assign moe = ((ir[31:26] == 5'b011000) | (ir[31:26] == 5'b011111));

  always @(posedge clk) begin
    pc <= pcin;
    y  <= yin;
    d  <= din;
    case (irsrc)
      0: ir <= irin;
      1: ir <= `BNE;
      default: ir <= `NOP;
    endcase
  end



endmodule
