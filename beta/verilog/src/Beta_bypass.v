`default_nettype none

module Beta_bypass (
    input [4:0] RFAin,
    input [31:0] RFDin,
    input [31:0] ALUin,
    input [31:0] MEMin,
    input [31:0] WBin,
    input [6:0] aP0,
    input [6:0] aP1,
    input [6:0] aP2,
    output [31:0] Dout,
    output stall
);
  //start

  wire aEq0;
  wire aEq1;
  wire aEq2;
  wire ready0;
  wire ready1;
  wire [31:0] intermediate1;
  wire [31:0] intermediate2;

  assign aEq0   = RFAin == aP0[4:0];
  assign aEq1   = RFAin == aP1[4:0];
  assign aEq2   = RFAin == aP2[4:0];

  assign ready0 = (aP0[6] || aP0[5]) && aEq0;
  assign ready1 = (aP1[6] || aP1[5]) && aEq1;

  assign stall  = ready0 || ready1;

  always_comb begin
    case (aEq1)
      1: intermediate1 = MEMin;
      0: intermediate1 = WBin;
    endcase
    case (aEq0)
      1: intermediate2 = ALUin;
      0: intermediate2 = intermediate1;
    endcase
    case (aEq0 || aEq1 || aEq2)
      1: Dout = intermediate2;
      default: Dout = RFDin;
    endcase
  end


endmodule
