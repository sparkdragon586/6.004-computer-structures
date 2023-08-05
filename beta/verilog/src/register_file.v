`default_nettype none

/*
 *  Blink a LED on the OrangeCrab using verilog
 */

module register_file (
    input clk,
    input [4:0] WriteAddress,
    input [31:0] WritePort,
    input WriteEnable,
    input [4:0] ReadAddress1,
    input [4:0] ReadAddress2,
    input rst,
    output [31:0] ReadPort1,
    output [31:0] ReadPort2
);
  // Create 32 32 bt registers
  reg [31:0] registers[31];
  integer i;
  // Every positive edge assign WritePort to WriteAddress if WriteEnable is
  // true
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      registers[i] <= 0;
    end
  end
  always @(posedge clk) begin
    if (!rst) begin
      if (WriteEnable & (WriteAddress !== 31)) begin
        registers[WriteAddress] <= WritePort;
      end
    end else begin
      for (i = 0; i < 32; i = i + 1) begin
        registers[i] <= 0;
      end
    end
  end
  // assign ReadPort1 to value of ReadAddress1 register
  assign ReadPort1 = (ReadAddress1 !== 31) ? registers[ReadAddress1] : 0;
  /*
  always_comb begin
      if (ReadAddress1 == 31) begin
          ReadPort1 = 32'h00000000;
      end else begin
          ReadPort1 = registers[ReadAddress1];
      end
  end
  */
  // assign ReadPort2 to value of ReadAddress2 register
  assign ReadPort2 = (ReadAddress2 !== 31) ? registers[ReadAddress2] : 0;
  /*
  always_comb begin
      if (ReadAddress2 == 31) begin
          ReadPort2 = 32'h00000000;
      end else begin
          ReadPort2 = registers[ReadAddress2];
      end
  end
  */


endmodule
