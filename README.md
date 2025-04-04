# Hamming74

## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
- [0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

- [1] M. M. Mano and M. D. Ciletti, Digital Design: With an Introduction to the Verilog HDL, VHDL, and SystemVerilog, 5th ed. Boston, MA, USA: Pearson, 2013.

- [2] B. Razavi, Design of Analog CMOS Integrated Circuits, 2nd ed. New York, NY, USA: McGraw-Hill Education, 2016.

## 3. Desarrollo
 - Joan Franco Sandoval 
 - Diego Navarro


### 3.0 Descripción general del sistema

El sistema desarrollado consiste en la implementación de un código de Hamming (7,4) utilizando la placa FPGA Tang Nano 9K. Se reciben dos señales de entrada a través de interruptores DIP (Deep Switch). La primera señal es un arreglo de 4 bits que se utiliza para generar el código de Hamming, el cual servirá como referencia para la segunda entrada. Esta segunda entrada es un arreglo de 7 bits que puede contener un error intencional, con el propósito de ser corregido mediante la verificación de paridad de bits.

Una vez identificado el error inducido, se despliega la información correspondiente tanto en el arreglo de LEDs de la FPGA como en un display de siete segmentos. Esta pantalla está controlada mediante transistores BJT y muestra no solo la posición del error detectado en la entrada del segundo interruptor DIP, sino también

### 3.1 Módulo 1

#### 1. Encabezado del módulo
```SystemVerilog
module top (
    input  [3:0] in,              // 4 bits de datos originales
    input  [6:0] dataRaw,         // Código Hamming con error manual (7 switches)
    input        selector,        // 0 = usar encoder | 1 = usar switches con error
    output [6:0] led,             // Muestra los 7 bits corregidos
    output [6:0] segments,        // Muestra el dato corregido en hexadecimal (4 bits)
    output [6:0] segments_error   // Muestra el bit donde se detectó el error
);
```
#### 2. Parámetros

????????????????????

#### 3. Entradas y salidas:

Entradas:
in: [3:0] (4 bits) - Datos originales.
dataRaw: [6:0] (7 bits) - Código Hamming con posible error.
selector: (1 bit) - Control para seleccionar entre el código Hamming generado o el manual.


Salidas:
led: [6:0] (7 bits) - Datos corregidos mostrados en LEDs.
segments: [6:0] (7 bits) - Dato corregido en formato hexadecimal.
segments_error: [6:0] (7 bits) - Bit donde se detectó el error.


#### 4. Criterios de diseño


#### 4.1 Introducción

Este módulo actúa como el control principal del código, donde se integran los demás módulos y se realizan las llamadas necesarias para asignar las variables correspondientes. Aquí se gestionan tanto las entradas como las salidas, asegurando que cada componente funcione de manera coordinada y eficiente.

#### 4.2 Explicación del Código

- 1. Declaración del Módulo
```SystemVerilog

module top (
    input  [3:0] in,
    input  [6:0] dataRaw,
    input        selector,
    output [6:0] led,
    output [6:0] segments,
    output [6:0] segments_error
);
```
module top: Define el módulo principal llamado top.
input: Se declaran las entradas del módulo, especificando el tamaño de cada una.
output: Se declaran las salidas del módulo, también especificando el tamaño.


- 2. Señales Internas
```SystemVerilog

wire [6:0] dataRaw_from_encoder;
wire [6:0] dataRaw_muxed;
wire [2:0] posError;
wire [6:0] dataCorregido;
wire [3:0] dataCorrecta;
wire [3:0] errorDisplay;

```
wire: Se declaran señales internas que se utilizarán para conectar diferentes módulos y almacenar resultados intermedios. Cada señal tiene un tamaño específico que se ajusta a los datos que manejará.

- 3. Instanciación de Módulos
```SystemVerilog

hamming74 encoder (
    .in(in),
    .ou(dataRaw_from_encoder)
);
```

hamming74 encoder: Se instancia un módulo llamado hamming74, que se encarga de codificar los datos. Se conectan las entradas y salidas mediante la notación de asignación de puertos.

- 4. Multiplexor
```SystemVerilog

assign dataRaw_muxed = selector ? dataRaw : dataRaw_from_encoder;
```

assign: Se utiliza para asignar valores a las señales. En este caso, se utiliza un operador ternario para seleccionar entre dos fuentes de datos basándose en el valor de selector.


- 5. Detección de Errores
```SystemVerilog

hamming_detection detector (
    .dataRaw(dataRaw_muxed),
    .posError(posError)
);
```

hamming_detection detector: Se instancia un módulo que se encarga de detectar errores en el código Hamming. Se conectan las señales de entrada y salida.

- 6. Corrección de Errores
```SystemVerilog

correccion_error corrector (
    .dataRaw(dataRaw_muxed),
    .sindrome(posError),
    .correccion(dataCorregido),
    .dataCorrecta(dataCorrecta)
);
```

correccion_error corrector: Se instancia un módulo que corrige el error detectado. Se conectan las señales necesarias para la corrección y la extracción de datos.

- 7. Visualización en LED
```SystemVerilog

display_7bits_leds display (
    .coregido(dataCorregido),
    .led(led)
);
```
display_7bits_leds display: Se instancia un módulo que se encarga de mostrar los datos corregidos en un conjunto de LEDs. Se conectan las señales de entrada y salida.

- 8. Visualización en 7 Segmentos
```SystemVerilog

sevseg display_hex(
    .bcd(dataCorrecta),
    .segments(segments)
);
```


sevseg display_hex: Se instancia un módulo que convierte los datos en formato BCD a un formato adecuado para un display de 7 segmentos. Se conectan las señales correspondientes.

- 9. Conversión de Posición de Error
```SystemVerilog
assign errorDisplay = (posError == 3'b000) ? 4'd0 : {1'b0, posError};
```

assign: Se utiliza nuevamente para asignar un valor a errorDisplay, que se utiliza para mostrar la posición del error en un formato adecuado.

- 10. Visualización del Error
```SystemVerilog

sevseg display_error(
    .bcd(errorDisplay),
    .segments(segments_error)
);
```
sevseg display_error: Se instancia otro módulo de visualización que muestra la posición del error en un display de 7 segmentos.


#### 4.3 Diagrama del Codificador Hamming (7,4)
https://github.com/joan000001/verilog.githttps://github.com/joan000001/verilog.githttps://github.com/joan000001/verilog.githttps://github.com/joan000001/verilog.git


#### 5. Testbench
Descripción y resultados de las pruebas hechas


### 3.2 Módulo 2

#### 1. Encabezado del módulo
```SystemVerilog
- module hamming74 (
  input logic [3:0] in,
  output logic [6:0] ou
);
```
#### 2. Parámetros

El módulo hamming74 implementa un código de Hamming (7,4), que es un esquema de corrección de errores que permite detectar y corregir errores en la transmisión de datos. Este código toma 4 bits de datos de entrada y genera 7 bits de salida, que incluyen los bits de datos originales y los bits de paridad necesarios para la corrección de errores.

#### 3. Entradas y salidas
- Entradas:
in: Un vector de 4 bits que representa los datos de entrada. Se espera que los bits de entrada sean in[3], in[2], in[1], y in[0].

- Salidas:
ou: Un vector de 7 bits que representa la salida codificada.
#### 4. Criterios de diseño


#### 4.1 Introducción
El código de Hamming (7,4) es un método de corrección de errores que permite la transmisión de datos de manera más confiable. Este código agrega bits de paridad a los datos originales para que, en caso de que se produzca un error durante la transmisión, se pueda detectar y corregir el error. En este módulo, se implementa la lógica necesaria para calcular los bits de paridad y organizar los bits de salida.

#### 4.2 Explicación del Código
El código se implementa en Verilog y se compone de un módulo llamado hamming74. A continuación se detalla la lógica del código:

1. Declaración del Módulo
```SystemVerilog
module hamming74 (
  input [3:0] in,
  output reg [6:0] ou
);
```
module hamming74: Define el módulo llamado hamming74.
input [3:0] in: Declara una entrada de 4 bits que representa los datos originales que se desean codificar.
output reg [6:0] ou: Declara una salida de 7 bits que contendrá el código Hamming generado. Se utiliza reg porque la salida se asigna dentro de un bloque always.

- 2. Declaración de Registros Internos
```SystemVerilog

reg d3, d5, d6, d7;
reg p1, p2, p4;
```
reg: Se declaran registros internos que se utilizarán para almacenar los bits de datos y paridad.
d3, d5, d6, d7: Representan los bits de datos originales.
p1, p2, p4: Representan los bits de paridad que se calcularán a partir de los bits de datos.

- 3. Bloque Always
```SystemVerilog

always @(*) begin
```
always @(*): Este bloque se ejecuta cada vez que hay un cambio en las señales de entrada. El uso de (*) indica que el bloque es sensible a todos los cambios en las señales de entrada.

- 4. Asignación de Bits de Datos
```SystemVerilog

d7 = in[3];
d6 = in[2];
d5 = in[1];
d3 = in[0];
```

Aquí se asignan los bits de entrada a los registros internos. Cada bit de in se asigna a un registro correspondiente (d3, d5, d6, d7).

- 5. Cálculo de Bits de Paridad


```SystemVerilog

p1 = d3 ^ d5 ^ d7;
p2 = d3 ^ d6 ^ d7;
p4 = d5 ^ d6 ^ d7;
```
XOR (^): Se utilizan operaciones XOR para calcular los bits de paridad:
p1: Paridad para el primer bit de paridad, que cubre los bits d3, d5 y d7.
p2: Paridad para el segundo bit de paridad, que cubre los bits d3, d6 y d7.
p4: Paridad para el cuarto bit de paridad, que cubre los bits d5, d6 y d7.


- 6. Asignación de la Salida
```SystemVerilog


ou[6] = d7;
ou[5] = d6;
ou[4] = d5;
ou[3] = p4;
ou[2] = d3;
ou[1] = p2;
ou[0] = p1;
```

Aquí se asignan los bits de datos y paridad a la salida ou. La salida se organiza de la siguiente manera:
ou[6]: Bit de datos d7.
ou[5]: Bit de datos d6.
ou[4]: Bit de datos d5.
ou[3]: Bit de paridad p4.
ou[2]: Bit de datos d3.
ou[1]: Bit de paridad p2.
ou[0]: Bit de paridad p1.

#### 4.3 Diagrama del Codificador Hamming (7,4)
https://github.com/joan000001/verilog.githttps://github.com/joan000001/verilog.githttps://github.com/joan000001/verilog.githttps://github.com/joan000001/verilog.git


#### 5. Testbench
Descripción y resultados de las pruebas hechas



### 3.3 Módulo 3

#### 1. Encabezado del módulo

```SystemVerilog
module hamming_detection (
  input [6:0] dataRaw,
  output reg [2:0] posError
);
```

#### 2. Parámetros

El módulo de detección de errores con código de Hamming recibe la señal dataRaw , proveniente directamente del Dish Switch conectado  a la FPGA. Esta señal está compuesta por un código de Hamming de 7 bits con un error inducido intencionalmente, permitiendo al usuario modificar la entrada para evaluar la implementación del sistema.

#### 3. Entradas y salidas
Entradas:
dataRaw: Un vector de 7 bits que representa los datos codificados que se han recibido. Este vector puede contener errores que deben ser detectados.
Salidas:
posError: Un vector de 3 bits que indica la posición del error detectado. Si no se detecta ningún error, el valor de posError será 000.
#### 4. Criterios de diseño
El diseño del módulo se basa en la capacidad del código de Hamming para detectar errores. Los criterios de diseño incluyen:

Detección de errores: El módulo debe ser capaz de identificar la posición de un solo error en los datos recibidos.
Simplicidad: La implementación debe ser clara y fácil de entender.
Eficiencia: La lógica de detección debe ser rápida y no consumir muchos recursos.
#### 4.1 Introducción

Gracias al uso de la paridad en los bits, el código de Hamming permite detectar errores al calcular la paridad de un arreglo de bits. En este proceso, cada bit de paridad se encarga de verificar tres bits de información.

#### 4.2 Explicación del Código


1. Declaración del Módulo
```SystemVerilog


module hamming_detection (
  input [6:0] dataRaw,
  output reg [2:0] posError
);
```
module hamming_detection: Define el módulo llamado hamming_detection.
input [6:0] dataRaw: Declara una entrada de 7 bits que representa el código Hamming que se va a verificar en busca de errores.
output reg [2:0] posError: Declara una salida de 3 bits que indicará la posición del error detectado. Se utiliza reg porque la salida se asigna dentro de un bloque always.

2. Cálculo de la Posición del Error
```SystemVerilog


posError[0] = dataRaw[0] ^ dataRaw[2] ^ dataRaw[4] ^ dataRaw[6];
posError[1] = dataRaw[1] ^ dataRaw[2] ^ dataRaw[5] ^ dataRaw[6];
posError[2] = dataRaw[3] ^ dataRaw[4] ^ dataRaw[5] ^ dataRaw[6];
```

XOR (^): Se utilizan operaciones XOR para calcular los bits de paridad que se utilizan para determinar la posición del error:
posError[0]: Se calcula utilizando los bits dataRaw[0], dataRaw[2], dataRaw[4] y dataRaw[6]. Este bit indica si hay un error en los bits que cubre.
posError[1]: Se calcula utilizando los bits dataRaw[1], dataRaw[2], dataRaw[5] y dataRaw[6]. Este bit también indica la presencia de un error en su conjunto de bits.
posError[2]: Se calcula utilizando los bits dataRaw[3], dataRaw[4], dataRaw[5] y dataRaw[6]. Este bit indica si hay un error en los bits que cubre.


#### 4.3 Diagrama del Codificador Hamming (7,4)



#### 5. Testbench
Descripción y resultados de las pruebas hechas


### 3.4 Módulo 4

#### 1. Encabezado del módulo
```SystemVerilog
- module correccion_error(
  input  logic [6:0] dataRaw,
  input  logic [2:0] sindrome,
  output logic [6:0] correccion,
  output logic [3:0] dataCorrecta
);
```
#### 2. Parámetros
El módulo ``` correccion_error ```  recibe la señal dataRaw , que proviene directamente del Dip Switch tras haber pasado por el módulo hamming_detection. Este sistema cuenta con parámetros configurables, lo que permite ajustar su comportamiento según las necesidades del usuario.



#### 3. Entradas y salidas

Entradas:
dataRaw: Un vector de 7 bits que representa los datos codificados que se han recibido, que pueden contener errores.
sindrome: Un vector de 3 bits que indica la posición del error detectado. Si no se detecta ningún error, el valor de sindrome será 000.


Salidas:
correccion: Un vector de 7 bits que representa los datos corregidos. Este vector es una copia de dataRaw, pero con el bit erróneo corregido si se detectó un error.
dataCorrecta: Un vector de 4 bits que representa los datos originales extraídos de los datos corregidos.

#### 4. Criterios de diseño

#### 4.1 Introducción

El código de Hamming no solo permite la detección de errores, sino que también permite la corrección de un solo error en los datos transmitidos. Este módulo se encarga de corregir el error en los datos recibidos utilizando el síndrome, que indica la posición del bit erróneo.

#### 4.2 Explicación del Código

- 1. Declaración del Módulo
```SystemVerilog


module correccion_error(
  input  [6:0] dataRaw,
  input  [2:0] sindrome,
  output reg [6:0] correccion,
  output reg [3:0] dataCorrecta
);
```

module correccion_error: Define el módulo llamado correccion_error.
input [6:0] dataRaw: Declara una entrada de 7 bits que representa el código Hamming que puede contener un error.
input [2:0] sindrome: Declara una entrada de 3 bits que representa el síndrome, que indica la posición del error detectado.
output reg [6:0] correccion: Declara una salida de 7 bits que contendrá el código Hamming corregido. Se utiliza reg porque la salida se asigna dentro de un bloque always.
output reg [3:0] dataCorrecta: Declara una salida de 4 bits que contendrá los datos originales extraídos del código Hamming corregido.
 
- 2. Inicialización de la Salida de Corrección
```SystemVerilog


correccion = dataRaw;

```
Se inicializa la señal correccion con el valor de dataRaw. Esto significa que, por defecto, la salida corregida será igual a la entrada, a menos que se detecte un error.
- 3. Corrección del Error
```SystemVerilog


if (sindrome != 3'b000) begin
    case (sindrome)
        3'b001: correccion[0] = ~correccion[0]; // Bit 1
        3'b010: correccion[1] = ~correccion[1]; // Bit 2
        3'b011: correccion[2] = ~correccion[2]; 
        3'b100: correccion[3] = ~correccion[3];
        3'b101: correccion[4] = ~correccion[4];
        3'b110: correccion[5] = ~correccion[5];
        3'b111: correccion[6] = ~correccion[6];
        default: /* no action */;
    endcase
end
```

if (sindrome != 3'b000): Se verifica si el síndrome indica que hay un error. Si sindrome es 000, no se realiza ninguna corrección.
case (sindrome): Se utiliza una estructura case para determinar qué bit debe ser corregido según el valor del síndrome.

Cada caso corresponde a un valor de sindrome que indica la posición del bit erróneo. Se utiliza la operación NOT (~) para invertir el bit correspondiente en correccion.
- 4. Extracción de Datos Originales
```SystemVerilog


dataCorrecta[3] = correccion[6];
dataCorrecta[2] = correccion[5];
dataCorrecta[1] = correccion[4];
dataCorrecta[0] = correccion[2];

```
Aquí se extraen los 4 bits de datos originales del código Hamming corregido. Los bits se asignan a dataCorrecta en el orden correspondiente:
dataCorrecta[3]: Bit de datos original correspondiente al bit 6 del código Hamming corregido.
dataCorrecta[2]: Bit de datos original correspondiente al bit 5.
dataCorrecta[1]: Bit de datos original correspondiente al bit 4.
dataCorrecta[0]: Bit de datos original correspondiente al bit 2.

#### 4.3 Diagrama del Codificador Hamming (7,4)


#### 5. Testbench
Descripción y resultados de las pruebas hechas




### 3.5 Módulo 5

#### 1. Encabezado del módulo
```SystemVerilog
- module display_7bits_leds (
  input  logic [6:0] coregido,
    output logic [6:0] led
);
```
#### 2. Parámetros

Este módulo no utiliza parámetros configurables, ya que se trata de una implementación fija de inversión de bits.

#### 3. Entradas y salidas:

Entradas:

coregido (7 bits): Representa la señal de entrada que se desea visualizar en los LEDs.

Salidas:

led (7 bits): Representa la salida invertida de la entrada coregido, que se conecta a un conjunto de LEDs.


#### 4. Criterios de diseño

#### 4.1 Introducción

- El diseño de este módulo sigue una arquitectura combinacional sencilla, donde la salida se calcula en función de la entrada sin necesidad de registros o almacenamiento temporal. Esto significa que los cambios en la entrada se reflejan inmediatamente en la salida.

#### 4.2 Explicación del Código

El código declara un módulo display_7bits_leds que cuenta con una entrada coregido de 7 bits y una salida led de 7 bits. La lógica dentro del bloque always @* realiza la inversión bit a bit de la entrada y asigna los valores resultantes a la salida led.

#### 4.3 Diagrama del Codificador Hamming (7,4)


#### 5. Testbench
Descripción y resultados de las pruebas hechas






















## 4. Consumo de recursos

## 5. Problemas encontrados durante el proyecto

## Apendices:
### Apendice 1:
texto, imágen, etc
