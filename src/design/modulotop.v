`timescale 1ns / 1ps

module top (
    input  [3:0] in,              // 4 bits de datos originales
    input  [6:0] dataRaw,         // Código Hamming con error manual (7 switches)
    input        selector,        // 0 = usar encoder | 1 = usar switches con error
    output [6:0] led,             // Muestra los 7 bits corregidos
    output [6:0] segments,        // Muestra el dato corregido en hexadecimal (4 bits)
    output [6:0] segments_error   // Muestra el bit donde se detectó el error
);

    // Señales internas
    wire [6:0] dataRaw_from_encoder;
    wire [6:0] dataRaw_muxed;
    wire [2:0] posError;
    wire [6:0] dataCorregido;
    wire [3:0] dataCorrecta;
    wire [3:0] errorDisplay; // Valor a mostrar en el display de error

    // Codificador Hamming 7,4 (convierte 4 bits en 7 bits)
    hamming74 encoder (
        .in(in),
        .ou(dataRaw_from_encoder)
    );

    // Multiplexor: si selector = 0 usa el valor del codificador; si = 1, usa el valor manual (con error)
    assign dataRaw_muxed = selector ? dataRaw : dataRaw_from_encoder;

    // Detección de errores
    hamming_detection detector (
        .dataRaw(dataRaw_muxed),
        .posError(posError)
    );

    // Corrección de errores: corrige el bit erróneo y extrae los 4 bits de dato original
    correccion_error corrector (
        .dataRaw(dataRaw_muxed),
        .sindrome(posError),
        .correccion(dataCorregido),
        .dataCorrecta(dataCorrecta)
    );

    // Visualización en LED (se invierte la señal, ya que los LED son activos en bajo)
    display_7bits_leds display (
        .coregido(dataCorregido),
        .led(led)
    );
    
    // Mostrar el dato corregido (4 bits) en el display de 7 segmentos
    sevseg display_hex(
        .bcd(dataCorrecta),
        .segments(segments)
    );
    
    // Convertir posError (3 bits) a 4 bits para mostrarlo en hexadecimal:
    // Si no hay error (posError == 000), se muestra 0.
    assign errorDisplay = (posError == 3'b000) ? 4'd0 : {1'b0, posError};

    // Mostrar el bit en el que se detectó el error en otro display de 7 segmentos
    sevseg display_error(
        .bcd(errorDisplay),
        .segments(segments_error)
    );

endmodule