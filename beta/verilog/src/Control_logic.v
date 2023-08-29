`default_nettype none

`define ADD 4'b0000
`define SUB 4'b0001
`define MUL 4'b0010
`define CMPEQ 4'b0100
`define CMPLT 4'b0101
`define CMPLE 4'b0110
`define AND 4'b1000
`define OR 4'b1001
`define XOR 4'b1010
`define XNOR 4'b1011
`define SHL 4'b1100
`define SHR 4'b1101
`define SRA 4'b1110
`define ILLEGALINSTRUCTION 11'b0011001xxxx
`define TRUE 1'b1
`define FALSE 1'b0

module Control_logic (
    input [5:0] opcode,
    input z,
    output [10:0] intermediateControl
);
  wire [10:0] intermediateControl;
  assign {wdsel[1:0], pcsel[1:0], mwr, moe, werf, alufn[3:0]} = intermediateControl;
  always_comb begin
    begin
      if (opcode[5]) begin
        if (!(opcode[3:0] == 4'b0011 | opcode[2:0] == 3'b111)) begin
          intermediateControl = {7'b0100000, opcode[4], `TRUE, opcode[3:0]};
        end else intermediateControl = `ILLEGALINSTRUCTION;
      end else begin
        case (opcode[2:0])
          3'b000: intermediateControl = {2'b10, 2'b00, 1'b0, 1'b1, 1'b1, `ADD};
          3'b001: intermediateControl = {2'bxx, 2'b00, 1'b1, 1'b0, 1'b0, `ADD};
          3'b011: intermediateControl = {2'b00, 2'b10, 1'b0, 6'b0xxxxx};
          3'b100: intermediateControl = {2'b00, (z ? 2'b00 : 2'b01), 1'b0, 1'b0, 5'b1xxxx};
          3'b110:  /*<-not in isa*/
          intermediateControl = {2'b00, (z ? 2'b00 : 2'b01), 1'b0, 1'b0, 5'b1xxxx};
          3'b101: intermediateControl = {2'b00, (z ? 2'b01 : 2'b00), 1'b0, 1'b0, 5'b1xxxx};
          3'b111: intermediateControl = {2'b10, 2'b00, 1'b0, 1'b1, 1'b1, `AND};
          default: intermediateControl = `ILLEGALINSTRUCTION;
        endcase
      end
    end
    /*
        case (opcode)
            default : `ILLEGALINSTRUCTION;
            6'b100000 : intermediateControl = {`FALSE,`TRUE,`ADD};
            6'b100001 : intermediateControl = {`FALSE, `TRUE, `SUB};
            6'b100010 : intermediateControl = {`FALSE, `TRUE, `MUL};
            6'b100100 : intermediateControl = {`FALSE, `TRUE, `CMPEQ};
            6'b100101 : intermediateControl = {`FALSE, `TRUE, `CMPLT};
            6'b100110 : intermediateControl = {`FALSE, `TRUE, `CMPLE};
            6'b101000 : intermediateControl = {`FALSE, `TRUE, `AND};
            6'b101001 : intermediateControl = {`FALSE, `TRUE, `OR};
            6'b101010 : intermediateControl = {`FALSE, `TRUE, `XOR};
            6'b101011 : intermediateControl = {`FALSE, `TRUE, `XNOR};
            6'b101100 : intermediateControl = {`FALSE, `TRUE, `SHL};
            6'b101101 : intermediateControl = {`FALSE, `TRUE, `SHR};
            6'b101110 : intermediateControl = {`FALSE, `TRUE, `SRA};
            6'b110000 : intermediateControl = {`TRUE,`TRUE,`ADD};
            6'b110001 : intermediateControl = {`TRUE, `TRUE, `SUB};
            6'b110010 : intermediateControl = {`TRUE, `TRUE, `MUL};
            6'b110100 : intermediateControl = {`TRUE, `TRUE, `CMPEQ};
            6'b110101 : intermediateControl = {`TRUE, `TRUE, `CMPLT};
            6'b110110 : intermediateControl = {`TRUE, `TRUE, `CMPLE};
            6'b111000 : intermediateControl = {`TRUE, `TRUE, `AND};
            6'b111001 : intermediateControl = {`TRUE, `TRUE, `OR};
            6'b111010 : intermediateControl = {`TRUE, `TRUE, `XOR};
            6'b111011 : intermediateControl = {`TRUE, `TRUE, `XNOR};
            6'b111100 : intermediateControl = {`TRUE, `TRUE, `SHL};
            6'b111101 : intermediateControl = {`TRUE, `TRUE, `SHR};
            6'b111110 : intermediateControl = {`TRUE, `TRUE, `SRA};
        endcase
        */
  end

endmodule
