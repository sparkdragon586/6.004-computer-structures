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

  // basic wires
  wire aEq0;
  wire aEq1;
  wire aEq2;
  wire ready0;
  wire ready1;
  wire [31:0] intermediate1;
  wire [31:0] intermediate2;

  // check if register requested is equal to register in a stage
  assign aEq0   = RFAin == aP0[4:0];
  assign aEq1   = RFAin == aP1[4:0];
  assign aEq2   = RFAin == aP2[4:0];

  // check to see if data in stage is ready
  assign ready0 = !(aP0[6] || aP0[5]) && aEq0;
  assign ready1 = !(aP1[6] || aP1[5]) && aEq1;

  // assert stall if data is not ready and register is not hardwired
  assign stall  = (ready0 || ready1) && (RFAin != 31);

  always_comb begin
    case (aEq1)  // if MEM stage contains pass data through MEM stage otherwise WB stage
      1: intermediate1 = MEMin;
      default: intermediate1 = WBin;
    endcase
    case (aEq0)  // if ALU stage contains data pass ALU through otherwise keep from stage one
      1: intermediate2 = ALUin;
      default: intermediate2 = intermediate1;
    endcase
    case (aEq0 || aEq1 || aEq2) // if a match is found pass it through, otherwise send data from register file
      1: Dout = (RFAin != 31) ? intermediate2 : RFDin;
      default: Dout = RFDin;
    endcase
  end


endmodule
