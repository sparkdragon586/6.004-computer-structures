`default_nettype none
// short hand operations
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

  // basic signals
  reg [31:0] pc = 0;  // initialize PC to zero
  reg [31:0] ir = `NOP;  // initialize IR to zero
  reg [31:0] y = 0;
  reg [31:0] d = 0;

  assign addr = y;  // used for relative addressing
  assign yout = y;  // used to store result to RF
  assign pcout = pc;  // pipeline signals
  assign irout = ir;
  assign wd = d;  // data to write
  assign mwr = (ir[31:26] == 5'b011001);  // Write enable
  assign moe = ((ir[31:26] == 5'b011000) | (ir[31:26] == 5'b011111));  // Read enable

  always @(posedge clk) begin
    pc <= pcin;  // pipeline registers
    y  <= yin;
    d  <= din;
    case (irsrc)  // IR control
      0: ir <= irin;
      1: ir <= `BNE;
      default: ir <= `NOP;
    endcase
  end



endmodule
