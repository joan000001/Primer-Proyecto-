`timescale 1ns/1ps

module top_tb;
    // Declaramos las señales de prueba
    reg [3:0] in;
    reg [6:0] dataRaw;
    reg       selector;
    wire [6:0] led;
    wire [6:0] segments;

    // Instanciación del módulo top
    top uut (
        .in(in),
        .dataRaw(dataRaw),
        .selector(selector),
        .led(led),
        .segments(segments)
    );

    initial begin
        $display("Caso | selector | in (ref) | dataRaw (error) | Corrected (7-bit) | 7seg (hex)");
        
        // Caso 1: Modo encoder (selector = 0)
        // Se usa la salida del codificador; dataRaw se ignora.
        selector = 0;
        in = 4'b1010;         // Valor de referencia para codificar
        dataRaw = 7'b0000000;  // No se utiliza en este modo
        #10;
        $display("  1   |   %b    |   %b   |    %b    |      %b      |  %b", 
                  selector, in, dataRaw, led, segments);
        
        // Caso 2: Modo error (selector = 1)
        // Se introduce manualmente un código Hamming con error.
        selector = 1;
        in = 4'b1010;         // Referencia: el codificador debería producir 1010101
                              // (para in=1010, según hamming74)
        // Introducimos un error: en vez de 1010101, se ingresa 1000101.
        dataRaw = 7'b1000101;
        #10;
        $display("  2   |   %b    |   %b   |    %b    |      %b      |  %b", 
                  selector, in, dataRaw, led, segments);
        
        // Caso 3: Otro valor en modo error
        selector = 1;
        in = 4'b0110;         // Referencia: el codificador debería producir 0110011
        // Introducimos un error, por ejemplo, cambiando el bit 0: 0110010.
        dataRaw = 7'b0110010;
        #10;
        $display("  3   |   %b    |   %b   |    %b    |      %b      |  %b", 
                  selector, in, dataRaw, led, segments);
        
        $finish;
    end

endmodule