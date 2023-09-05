`default_nettype none

/*
 *  Blink a LED on the OrangeCrab using verilog
 */


module Beta_ALU (
    input clk,
    input [3:0] AluFn,
    input [31:0] InA,
    input [31:0] InB,
    output [31:0] Result
);

  `define LOGIC 3
  `define ADVANCED 2
  `define SWITCH 1
  `define FINAL 0

  // Create a 27 bit register
  wire [31:0] Aintermediate;
  wire [31:0] Bintermediate;
  wire [31:0] intermediate;
  wire cmpeq;
  wire cmplt;

  // Every positive edge increment register by 1
  assign cmpeq = InA == InB;
  assign cmplt = InA < InB;
  always_comb begin
    if (AluFn[2:0] == 1) begin
      Aintermediate = ~InA;
    end else begin
      Aintermediate = InA;
    end
    case (AluFn[`FINAL])
      0: Bintermediate = InB;
      1: Bintermediate = ~InB;
    endcase
    if (AluFn[`LOGIC]) begin
      if (!AluFn[`ADVANCED]) begin
        case (AluFn[`SWITCH])
          0: intermediate = Aintermediate & Bintermediate;
          1: intermediate = InA ^ InB;
        endcase
      end else begin
        case (AluFn[1:0])
          2'b01:   intermediate = InA >> InB;
          2'b10:   intermediate = InA >>> InB;
          default: intermediate = InA << InB;
        endcase
      end
    end else begin
      if (!AluFn[`ADVANCED]) begin
        case (AluFn[`SWITCH])
          1: intermediate = InA * InB;
          default: intermediate = Aintermediate + InB;
        endcase
      end else begin
        case (AluFn[1:0])
          0: intermediate = cmpeq;
          1: intermediate = cmplt;
          default: intermediate = cmpeq | cmplt;
        endcase
      end
    end
    Result = (AluFn[`FINAL] && !AluFn[`ADVANCED] && !(AluFn == 4'b0010)) ? ~intermediate : intermediate;
  end




endmodule
