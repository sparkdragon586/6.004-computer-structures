`default_nettype none
`define RESET 32'h0
`define ILLOP 32'h4
`define XADR 32'h8





module Beta_IF (
    input clk,
    input stall,
    input [31:0] cRelativeA,
    input [31:0] jt,
    input [31:0] memWaitAddr,
    input [2:0] PCSEL,
    output [31:0] pcOut,
    output [31:0] iAddress,
    input [31:0] iData,
    output [31:0] irout
);

  reg  [31:0] pc;
  wire [31:0] pcNext;

  assign iAddress = pc;
  assign pcNext = pc + 4;
  assign pcOut = pcNext;
  assign irout = iData;

  always @(posedge clk) begin
    if (stall) begin
      pc <= pc;
    end else begin
      case (PCSEL)
        default: pc <= `ILLOP;
        0: pc <= pcNext;
        1: pc <= cRelativeA;
        2: pc <= jt;
        3: pc <= `ILLOP;
        4: pc <= `XADR;
        5: pc <= memWaitAddr;
      endcase
    end
  end



endmodule
