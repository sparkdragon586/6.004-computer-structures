`default_nettype none


module Beta_MMU (
    input clk,
    input [15:0] contextNum,
    input [31:0] pTblePtr,
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
    input MemDataReady,
    output MemReadEnable,
    output MemWriteEnable,
    input CacheClearEnable,
    input PortAEnable,
    input PortBReadEnable,
    input PortBWriteEnable,
    input rst
);
  reg [7:0] Memory[4][64][64];
  reg [21:0] Tag[4][64];
  wire [31:0] AddressLookup[4];
  reg [31:0] fillCache[2];
  reg cacheMiss[2];
  integer i;
  integer j;
  wire foundMatchTlbA;
  reg [31:0] tlb[32];
  reg [46:0] tlbTag[32];
  reg tlbFull[32];
  wire [31:0] portAPhysicalAddrTlb;
  wire [31:0] portAPhysicalAddr;
  wire portATlbHit;

  // tlb
  always_comb begin
    //port a tlb access
    foundMatchTlbA = 0;
    portAPhysicalAddrTlb = 0;
    portATlbHit = 0;
    for (i = 0; i < 32; i = i + 1) begin
      if (tlbTag[i] == {contextNum, APortAddress} && !foundMatchTlbA && tlbFull[i]) begin
        portAPhysicalAddrTlb = tlb[i];
        portATlbHit = 1;
        foundMatchTlbA = 1;
      end
    end
  end
  wire foundMatchCache[2];
  wire cacheHit[2];
  wire [31:0] cacheData[2];

  always_comb begin
    cacheHit[0]  = 0;
    cacheData[0] = 0;
    for (i = 0; i < 4; i = i + 1) begin
      if (Tag[i][APortAddress[11:6]][21] && (Tag[i][APortAddress[11:6]][0:19] == portAPhysicalAddr[31:12]) && !cacheHit[0]) begin
        cacheHit[0] = 1;
      end
    end
  end

endmodule
