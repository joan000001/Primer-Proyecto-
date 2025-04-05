`timescale 1ns/1ps

module top_tb;

    // === Señales para top ===
    reg [3:0] in;
    reg [6:0] dataRaw;
    reg       selector;
    wire [6:0] led;
    wire [6:0] segments;
    wire [6:0] segments_error;

    top uut (
        .in(in),
        .dataRaw(dataRaw),
        .selector(selector),
        .led(led),
        .segments(segments),
        .segments_error(segments_error)
    );

    // === Señales y pruebas para módulos individuales ===

    // hamming74
    reg  [3:0] in_enc;
    wire [6:0] out_enc;
    hamming74 encoder_tb (
        .in(in_enc),
        .ou(out_enc)
    );

    // hamming_detection
    reg  [6:0] data_det;
    wire [2:0] pos_error;
    hamming_detection detection_tb (
        .dataRaw(data_det),
        .posError(pos_error)
    );

    // correccion_error
    reg  [6:0] data_corr;
    reg  [2:0] sindrome;
    wire [6:0] corregido;
    wire [3:0] data_correcta;
    correccion_error correction_tb (
        .dataRaw(data_corr),
        .sindrome(sindrome),
        .correccion(corregido),
        .dataCorrecta(data_correcta)
    );

    // display_7bits_leds
    reg  [6:0] coregido_leds;
    wire [6:0] leds_out;
    display_7bits_leds leds_tb (
        .coregido(coregido_leds),
        .led(leds_out)
    );

    // sevseg
    reg  [3:0] bcd_val;
    wire [6:0] seg_out;
    sevseg seg_tb (
        .bcd(bcd_val),
        .segments(seg_out)
    );

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        $display("Iniciando pruebas...");
        $display("==================================== Pruebas individuales ======================================");

        // === hamming74 ===
        in_enc = 4'b1010;
        #1;
        $display("hamming74: in=%b => out=%b", in_enc, out_enc);
        in_enc = 4'b1111;
        #1;
        $display("hamming74: in=%b => out=%b", in_enc, out_enc);
        in_enc = 4'b0000;
        #1;
        $display("hamming74: in=%b => out=%b", in_enc, out_enc);

        $display("================================================================================================");
        $display("================================================================================================");


        // === hamming_detection ===
        data_det = 7'b1000101;  
        #1;
        $display("hamming_detection: dataRaw=%b => posError=%b", data_det, pos_error);
        data_det = 7'b0000001;  
        #1;
        $display("hamming_detection: dataRaw=%b => posError=%b", data_det, pos_error);
        data_det = 7'b0111111;  
        #1;
        $display("hamming_detection: dataRaw=%b => posError=%b", data_det, pos_error);

        $display("================================================================================================");
        $display("================================================================================================");

        // === correccion_error ===
        data_corr = 7'b1000101;
        sindrome = 3'b101;  
        #1;
        $display("correccion_error: in=%b, sindrome=%b => corregido=%b, dato=%b",
                 data_corr, sindrome, corregido, data_correcta);
        data_corr = 7'b0000001;
        sindrome = 3'b001;  
        #1;
        $display("correccion_error: in=%b, sindrome=%b => corregido=%b, dato=%b",
                 data_corr, sindrome, corregido, data_correcta);
        data_corr = 7'b0111111;
        sindrome = 3'b111; 
        #1;
        $display("correccion_error: in=%b, sindrome=%b => corregido=%b, dato=%b",
                 data_corr, sindrome, corregido, data_correcta);

        $display("================================================================================================");
        $display("================================================================================================");

        // === display_7bits_leds ===
        coregido_leds = 7'b1010101;
        #1;
        $display("display_7bits_leds: in=%b => leds=%b", coregido_leds, leds_out);
        coregido_leds = 7'b1111111;
        #1;
        $display("display_7bits_leds: in=%b => leds=%b", coregido_leds, leds_out);
        coregido_leds = 7'b0000000;
        #1;
        $display("display_7bits_leds: in=%b => leds=%b", coregido_leds, leds_out);

        $display("================================================================================================");
        $display("================================================================================================");

        // === sevseg ===
        bcd_val = 4'hA; 
        #1;
        $display("sevseg: bcd=%h => seg=%b", bcd_val, seg_out);
        bcd_val = 4'h0; 
        #1;
        $display("sevseg: bcd=%h => seg=%b", bcd_val, seg_out);
        bcd_val = 4'h2; 
        #1;
        $display("sevseg: bcd=%h => seg=%b", bcd_val, seg_out);
        bcd_val = 4'h9; 
        #1;
        $display("sevseg: bcd=%h => seg=%b", bcd_val, seg_out);
        

         $display("================================================================================================");
        $display("================================================================================================");
        $display("========================== Pruebas del modulo top ================================");

        // === Pruebas top ===
        $display("Caso | selector | in (ref) | dataRaw (error) | Corrected (7-bit) | 7seg (hex)");
        
        // Caso 1: Modo encoder (selector = 0)
        selector = 0;
        in = 4'b1010;
        dataRaw = 7'b0000000; 
        #10;
        $display("  1   |   %b    |   %b   |    %b    |      %b      |  %b", 
                  selector, in, dataRaw, led, segments);
        
        // Caso 2: Modo error (selector = 1)
        selector = 1;
        in = 4'b1010;
        dataRaw = 7'b1000101;
        #10;
        $display("  2   |   %b    |   %b   |    %b    |      %b      |  %b", 
                  selector, in, dataRaw, led, segments);

        // Caso 3: Otro valor en modo error
        selector = 1;
        in = 4'b0110;
        dataRaw = 7'b0110010;
        #10;
        $display("  3   |   %b    |   %b   |    %b    |      %b      |  %b", 
                  selector, in, dataRaw, led, segments);

        $finish;
    end

endmodule
