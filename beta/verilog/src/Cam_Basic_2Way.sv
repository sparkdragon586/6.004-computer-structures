`default_nettype none

module Cam_Basic_2Way (
    input clk,
    input rst,
    input invalidate,
    input WE,
    input [20] write_addr,
    input [32] write_data,
    input [19] port_1_lookup,
    output [32] port_1_result,
    input [19] port_2_lookup,
    output [33] port_2_result
);

  // create 2 sets for cache
  reg [34] Set1[2048];
  reg [34] Set2[2048];

  wire [34] Set1_Indexed[2];
  wire [34] Set2_Indexed[2];

  wire [2] Cache_Hit[2];

  always @(posedge clk) begin
    // invalidate cache initially
    if (rst) begin
      for (int i = 0; i < 2048; i = i + 1) begin
        Set1[i] <= 34'bxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxx;
        set2[i] <= 34'bxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxx;
      end
    end else begin

      // write into cache
      if (WE) begin
        case (write_addr[19])
          1'b0: begin
            Set1[write_addr[10:0]] <= {write_addr[18:11], write_data[25:0]};
          end
          1'b1: begin
            Set2[write_addr[10:0]] <= {write_addr[18:11], write_data[25:0]};
          end
          default: begin
          end
        endcase
      end
    end
  end

  always_comb begin
    Set1_Indexed[0] = Set1[port_1_lookup[10:0]];
    Set2_Indexed[0] = Set2[port_1_lookup[10:0]];
    if (rst || WE) begin
      Set1_Indexed[1] = 0;
      Set2_Indexed[1] = 0;
    end else begin
      Set1_Indexed[1] = Set1[port_2_lookup[10:0]];
      Set2_Indexed[1] = Set2[port_2_lookup[10:0]];
    end
  end

endmodule
