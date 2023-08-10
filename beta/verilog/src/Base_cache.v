`default_nettype none


module Base_cache (
    input clk,
    input [31:0] APortAddress,
    output [31:0] APortData,
    output AReady,
    input [31:0] BPortAddress,
    output [31:0] BPortDataOut,
    output BReady,
    input [31:0] BPortDataIn,
    output [31:0] MemAddress,
    output [31:0] MemDataOut,
    input [31:0] MemDataIn,
    input [31:0] CacheClearAddress,
    input CacheClearEnable,
    input PortAEnable,
    input PortBReadEnable,
    input PortBWriteEnable,
    input rst
);
  reg [7:0] Memory[64][64][4];
  reg [21:0] Tag[64][4];
  wire [31:0] AddressLookup[2];
  integer i;
  integer j;

  always_comb begin
    for (i = 0; i < 2; i = i + 1) begin

    end
  end

endmodule
