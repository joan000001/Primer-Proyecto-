`timescale 1ns / 1ps

module hamming_detection (
  input [6:0] dataRaw,
  output reg [2:0] posError
);
  always @(*) begin
    posError[0] = dataRaw[0] ^ dataRaw[2] ^ dataRaw[4] ^ dataRaw[6];
    posError[1] = dataRaw[1] ^ dataRaw[2] ^ dataRaw[5] ^ dataRaw[6];
    posError[2] = dataRaw[3] ^ dataRaw[4] ^ dataRaw[5] ^ dataRaw[6];
  end
endmodule