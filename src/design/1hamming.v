`timescale 1ns / 1ps

module hamming74 (
  input [3:0] in,
  output reg [6:0] ou
);
  reg d3, d5, d6, d7;
  reg p1, p2, p4;

  always @(*) begin
    d7 = in[3];
    d6 = in[2];
    d5 = in[1];
    d3 = in[0];
    p1 = d3 ^ d5 ^ d7;
    p2 = d3 ^ d6 ^ d7;
    p4 = d5 ^ d6 ^ d7;
    
    ou[6] = d7;
    ou[5] = d6;
    ou[4] = d5;
    ou[3] = p4;
    ou[2] = d3;
    ou[1] = p2;
    ou[0] = p1;
  end
endmodule