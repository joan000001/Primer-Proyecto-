`timescale 1ns / 1ps

module display_7bits_leds (
    input [6:0] coregido,
    output reg [6:0] led
);
    always @* begin
        led[0] = ~coregido[0];
        led[1] = ~coregido[1];
        led[2] = ~coregido[2];
        led[3] = ~coregido[3];
        led[4] = ~coregido[4];
        led[5] = ~coregido[5];
        led[6] = ~coregido[6];
    end
endmodule