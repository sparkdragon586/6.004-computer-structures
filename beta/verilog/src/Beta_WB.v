`default_nettype none
`define NOP 32'b10000011111111111111111111111111
`define BNE 32'b01111011110111111111111111111111

module Beta_WB (
    input clk,
    input [1:0] irsrc,
    input [31:0] pcin,
    input [31:0] irin,
    input [31:0] yin,
    input [31:0] rd,
    input memwait,
    output [4:0] wa,
    output [31:0] wd,
    output WERF
);

  reg  [31:0] pc = 0;
  reg  [31:0] ir = `NOP;
  reg  [31:0] y = 0;
  wire [ 1:0] WDSEL;

  assign WERF = (!(ir[31:26] == 6'b011001) && !memwait);
  assign wa   = ir[25:21];

  always_comb begin
    case (WDSEL)
      default: wd = pc;
      1: wd = y;
      2: wd = rd;
    endcase
  end

  always_comb begin
    if (ir[31]) begin
      WDSEL = 1;
    end else begin
      if (ir[30:26] == 5'b11000 || ir[30:26] == 5'b11111) begin
        WDSEL = 2;
      end else begin
        WDSEL = 0;
      end
    end
  end

  always @(posedge clk) begin
    if (!memwait) begin
      pc <= pcin;
      y  <= yin;
      case (irsrc)
        0: ir <= irin;
        1: ir <= `BNE;
        default: ir <= `NOP;
      endcase
    end
  end


endmodule
