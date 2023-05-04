# PostgreSQL

Postgres es una BBDD relacional.
Guardar datos y recuperalos.

Esos datos donde acaban guardados?  En un ficheros en disco.
Esos datos pueden tener distinta naturaleza: TIPOS DE DATOS:
NUMERICOS:
    Enteros
    Decimales
TEXTO:
    De ancho fijo
    De ancho variable
    Enormes
FECHAS:
    FECHAS
    HORA
    TIMESTAMPS
LOGICOS

Qué estructura tienen esos ficheros? Cómo operamos sobre esos ficheros?
Hay 2 formas de manipular ficheros en un SO:
- Acceso secuencial:    VIENE BIEN si trabajo con ficheros pequeños
  - Escribir: Escribo el fichero entero o le añado cosas al final (append)
  - Lectura: Leo el fichero completo
- Acceso aleatorio:     VIENE BIEN para archivos grandes.
  Puedo poner la aguja del HDD en cualquier posición del archivo... para leer o escribir
    Ventajas: 
        - Más rápido leer y escribir datos discretos
    Desventajas: 
        - Más complejo
        - Los datos ocupan más... MUCHO MAS !!!

Los datos se almacenan como una secuencia de bytes:1 bytes = 8 bits

1 bit: Podemos a llegar a almacenar hasta 2 valores diferentes: 0 | 1
Otra cosa es el SIGNIFICADO de ese 0 o ese 1 que estoy guardando.
Parte de ese significado viene dato por el tipo de datos:

1 bit:      Hasta 2 valores diferentes
2 bits:           4
3 bits;           8
8 bits / 1 byte:  256

                                TIPO DE DATOS
                                    NUMEROS ENTEROS         TEXTOS
0000 0000   -> SIGNIFICADO?             0       -128
0000 0001                               1
0010 0001
0001 0110
1111 1111                               255     127

Cuando guardo un texto.... cuanto ocupa cada carácter?  
DEPENDE DEL JUEGO DE CARACTERES (codificación, encoding, collate)
ASCII 127
UTF-8

UNICODE: En un juego de caracteres que incluye "todos" los caracteres que usa la humanidad en su conjunto? + 200.000 caracteres
UTF: UNICODE TRANSFORMATION FORMAT
    UTF-8   1 carácter ocupa entre 1 y 4 bytes
    UTF-16  1 carácter ocupa entre 2 y 4 bytes
    UTF-32  1 carácter ocupa 4 bytes
    ISO-8859-1

# Ejemplo de tabla de datos: TABLA: RECETAS DE COCINA!

| Título                | Tipo de plato | Ingrediente | Dificultad | Duración |
| Paella de marisco     | principal     | Arroz       | media      | 2        |
| Arroz con bogavante   | principal     | Bogavante   | media      | 1.5      |
| Corderito asado       | principal     | Cordero     | media      | 3        |
| Tartar de salmón      | principal     | salmón      | baja       | 0.5      |
| Ceviche de salmón     | principal     | salmón      | baja       | 1        |
| Salmonetes            | principal     | Salmonetes  | baja       | 1        |

Cual sería la forma más eficiente de guardar esta información en el HDD, si la información no fuese a ser modificada y si yo quisiera leer todas las recetas cada vez que abro el fichero?

    Paella de marisco|principal|Arroz|media|2|Arroz con bogavante|principal|Arroz|media|1.5|Corderito asado con patatas a lo pobre|principal|Cordero|media|3|Tartar de salmón|principal|salmón|baja|0.5|Ceviche de salmón|principal|salmón|baja|1|Salmonetes|principal|Salmonetes|baja|1|

Si voy a estar:
- Actualizando datos discretos 
- Tratando de recuperar datos discretos

# Tabla optimizada para acceso aleatorio:

     100 bytes                20 bytes        20 bytes      1 bytes      4 bytes    --> 145 bytes
    | Título                | Tipo de plato | Ingrediente | Dificultad | Duración |
    | Paella de marisco     | principal     | Arroz       | media      | 2        |
    | Arroz con bogavante   | principal     | Bogavante   | media      | 1.5      |
    | Corderito asado       | principal     | Cordero     | media      | 3        |
    | Tartar de salmón      | principal     | salmón      | baja       | 0.5      |
    | Ceviche de salmón     | principal     | salmón      | baja       | 1        |
    | Salmonetes            | principal     | Salmonetes  | baja       | 1        |

Quiero las recetas cuyo ingrediente principal sea "salmón".
Para el primer dato, donde pongo la aguja del HDD? 120
Y a partir de ahí, sumo 145

Esa operación en las BBDD cómo se llama? Full Scan . ESTO ESTA GUAY ! comparado con el acceso secuencial

Cómo puedo optimizar esa búsqueda? Teniendo los datos ordenados.
Por qué? Algoritmo BÚSQUEDA BINARIA!
Desde que tenéis 8 años... cada vez que usáis un DICCIONARIO! o una enciclopedia.

    > MANZANA !
    20.000 términos
    10.000 NARANJA Acabo de descartar 10.000 datos... en los que ya NO HE DE BUSCAR !
     5.000 DATIL   Acabo de descartar  5.000 datos... en los que ya NO HE DE BUSCAR !
     7.500
     8.750 MANZANO


1000000 datos
 500000
 250000
 125000
  63000
  32000
  16000
   8000
   4000
   2000
   1000
    500
    250
    125
     65
     33
     17
      9
      5
      3
      2
      1
        22 tiradas, tengo el dato que me interesa entre 1000000 de datos !


    > ZAPATO
    Por donde abrís el diccionario? Por la mitad? NO... por el final. por qué?
    A   1 palabra
    B   1 palabra
    ...
    Y   1 palabra
    Z   999965 palabras

    En mi cabeza conozco "más o menos" cómo se distribuyen los datos en el diccionario.
    Cuantas palabras hay de cada letra
    Cuantas letras hay en total

    Las BBDD también hacen esto => ESTADISTICAS !

Todo esto, de la búsqueda binaria está guay... pero requiere tener los datos ordenados.
Y si no lo están?
- Full scan
- ordenar los datos. Esto no me lo planteo... me tarda más que hacer un fullscan!

Qué tal se le da a un ORDENADOR ordenar datos? FATAL !!!!

Con lo cual... si quiero tener un acceso rápido al dato (que tendrá un impacto en lectura / escritura) necesito los datos pre-ordenados.
Esto tiene un problema.... por cuantos campos puedo tener un conjunto de datos pre-ordenado?
Puedo tenerlos ordenados por UN CAMPO !!!!
Cómo resuelvo ésto? Creando INDICES !

# Qué es un índice?

UNA COPIA ORDENADA DE LOS DATOS (UNICOS) con sus respectivas ubicaciones

En una biblioteca el INDICE era un armario lleno de cajoncitos:
A
B
C
D
E
F
Dentro de los cajones, teniamos FICHAS:
ARMARIO con los libros ordenador por AUTORES:
A
B
C
     Cervantes
        Libro 1 -> Pasillo 17, estantería 15, sección 4
        Libro 2

     100 bytes                20 bytes        20 bytes      1 bytes      4 bytes    --> 145 bytes
    | Título                | Tipo de plato | Ingrediente | Dificultad | Duración |
    | Paella de marisco     | principal     | Arroz       | media      | 2        |
    | Arroz con bogavante   | principal     | Bogavante   | media      | 1.5      |
    | Corderito asado       | principal     | Cordero     | media      | 3        |
    | Tartar de salmón      | principal     | salmón      | baja       | 0.5      |
    | Ceviche de salmón     | principal     | salmón      | baja       | 1        |
    | Salmonetes            | principal     | Salmonetes  | baja       | 1        |
    | Besugo                | principal     | Besugo      | media      | 2        |

INDICE POR: 
    ingrediente     FILA

    Arroz           1
    
                            <<< PADDING FACTOR 
    Besugo          7
    
    
    Bogavante       2
    

    Cordero         3
    

    Salmón          4,5


    Salmonetes      6
    

INDICE POR: 
    duración        FILA
    0.5             4
    1               5,6
    1.5             2
    2               1
    3               3

# Indices invertidos / inversos

Título
------------------------
Paella de marisco
Arroz con bogavante
Corderito asado
Tartar de salmón
Ceviche de salmón
Salmonetes
Besugo
Paella de marisco
Salpicón de marisco
Crema de marisco

## Indice directo:
    Arroz con bogavante         2
    Besugo                      7
    Ceviche de salmón           5
    Corderito asado             3
    Crema de marisco           10
    Paella de marisco           1, 8
    Salmonetes                  6
    Salpicón de marisco         9
    Tartar de salmón            4

Qué operaciones ELEMENTALES me permite hacer este tipo de índice?
- IGUALDAD: que un valor del índice es igual a un valor que me suministran en una query?
    > SELECT * FROM recetas WHERE titulo = "Besugo";
- DISTINTO
- MAYOR QUE (o igual)
- MENOR QUE (o igual)
- LIKE con % al final
    > SELECT * FROM recetas WHERE titulo LIKE "Besugo%";        <   AUTOCOMPLETAR !

    > SELECT id FROM recetas WHERE TO_UPPER(titulo) LIKE "%MARISCO%";      <   FULL SCAN del indice
        En el indice hay menos datos (me he quitado los duplicados)
        Esto no me haría una búsqueda binaria....

        ESTO EN GENERAL EN LAS BBDD es una operación DESASTROSA !!!!!

## Indice inverso:
    arroz-*-bogavante         2
    besugo                      7
    ceviche-*-salmon           5
    corderito-asado             3
    crema-*-marisco           10
    paella-*-marisco           1, 8
    salmonetes                  6
    salpicon-*-marisco-receta-*-*-@abuela77-*-*-carlos        9
    tartar-*-salmon            4

PASO 1: TOKENIZAR
PASO 2: ELIMINAR PALABRAS VACIAS DE SIGNIFICADO (stop words -> Esto depende del idioma)
PASO 3: NORMALIZAR CARACTERES ESPECIALES y USO MAYUSCULAS/MINUSCULAS
PASO 4: Quitar terminaciones de "GENERO", "PLURAL", "DIMINUTIVOS", "AUMENTATIVOS", "RAIZ"
PASO 5: Extraer e indexar los tokens

    arroz       2(1)
    besugo      7(1)
    bogavante   2(3)
    ...
    marisco     10(3), 1(3), 8(3), 9 (3)
    salmon      5(3), 4 (3), 6(1)

# Algoritmos de huella (HASH)

Los Algoritmos de huella los usamos en la vida cotidiana:

Letra del DNI: Función que dado un dato original genera siempre el mismo dato de salida
De la salida no puedo regenerar el dato original

23.000.000 T
 Sacar el resto de la division entera del numero entre 23
    23.000.000 | 23
               -------------
             0   1.000.000
             ^ Ese es el dato que me interesa... que estaré entre qué valores? 0-22

El dato de salida no tiene porque ser UNICO. 
DOS DATOS DISTINTOS PUEDEN PRODUCIR LA MISMA HUELLA: COLISION! Probabilidad de 1/23 en sacar un número que produzca la misma huella... > 95%

Esto en las BBDD lo usamos con frecuencia:
- Guardar una contraseña! Encriptada? Me temo que no!
    Si alguien me gana la BBDD... cono tiempo puede desencriptar las contraseñas... 
    Y por ende sacar el valor original de la contraseña
  En este caso, es habitual guardar una huella de la contraseña!
- Generar un índice. La gracia de una huella, es que suelen ser datos NUMERICOS lo que generan
  Los datos numéricos suelen ocupar mucho menos espacio en almacenamiento que los textos.
    En un índice, en lugar de el dato original (TEXTO MUY LARGO), puedo guardar su huella
    Con esto gano: ESPACIO DE ALMACENAMIENTO: Velocidad en I/O
                   Velocidad en la comparaciones
  En este caso, que operaciones ELEMENTALES podré hacer usando el índice:
  - IGUALDAD / DISTINTO
---

# Nota 1

Tengo que guardar en una BBDD un DNI (español)... me interesa guardar el DNI como texto
o como número.

1 bytes: 256 valores
2 bytes: 256x256 = 65600
4 bytes = > 4kM Me entran todos los DNIS

Si lo guardo como texto: 7x9 = 63/8 -> 8 bytes

# Nota 2

Quien debe garantizar que el DNI que llega a la BBDD es correcto? 
Que la letra coincide con el número, con independencia de cómo lo guarde

- La aplicación? La persona que me pase los datos

- La BBDD... Es el garante del dato. Su misión es almacenar la información... y voy a guardar información VALIDA!
  - El problema de delegar esto a la app... es que mañana una app2... o una persona 2 entre en la BBDD con su propio criterio con respecto a los DNIs

Durante muchos años (hace más de 20 años) estaba muy de moda meter LOGICA EN LAS BBDD.
Admiten eso las BBDD? PL/SQL

    Llegamos a la conclusión de que esto no era buena práctica... y que esa lógica debía estar en la app... (O parte de ella y esto no se tuvo en cuenta)

    Y ... hay lógica de negocio: APP
    también hay lógica de los datos: BBDD

---

# Con que entornos trabajamos habitualmente en una empresa

- Desarrollo
- Pre-producción, test, q&a, integración
- Producción **

## Qué características debe tener el entorno de producción que lo diferencian de otros entornos?

- ALTA DISPONIBILIDAD ***
    Tratar de garantizar un determinado tiempo de servicio pactado contractualmente         
        90%         RUINA           1 de cada 10 días, el sistema OFFLINE                           |   €
        99%                         1 de cada 100 días el sistema OFFLINE                           |   €€
        99,9%                       1 de cada 1000 días:  8 horas al año! BANCO /WEB MERCADONA      |   €€€€€
        99.99%                      minutos (20 minutos) HOSPITAL                                   v   €€€€€€€€€€€€€

    Tratar de garantizar la NO PERDIDA DE INFORMACION

    Cómo tratamos de asegurar ese tiempo de servicio?  REDUNDANCIA

- ESCALABILIDAD
    Capacidad de ajustar la infra a las necesidades de cada momento. 
        BBDD -> Según pasa el tiempo, su uso (los recursos que necesitan) tienden a AUMENTAR

        Web telepizza
            00:00       -> 0
            11:00       -> 0
            13          -> 4
            14:00          400
            17:00          0
            21:00          100000000

    Cuando necesito más recursos: NECESITAMOS ESCALAR 
        Escalado Vertical           más máquina !!!
        Escalado Horizontal         más máquinas !!!

---
En el mundo de las bbdd, en los entornos de producción optamos por 3 estrategias diferentes!
- BBDD Standalone:
    1 sola instancia de la BBDD, con sus ficheros de sus datos (los almacenaré de forma segura: REDUNDANTE: RAID, cabina...)
    En los entornos de producción: ES MUY UTILIZADO
    Sobre todo hoy en día, que trabajamos mucho con Contenedores: KUBERNETES
- BBDD Replicación
    1 sola instancia de la BBDD para escritura
    Copias de la BBDD para lectura
        - Backups... y no quiero detener/afectar producción
        - Consultas BI
    Ofrecer HA... Si la primaria CAE, una replica puede actuar de PRIMARIA (esto con cuidado, nos da dolores de cabeza !)
- Cluster BBDD ACTIVO-ACTIVO
    Multiples instancia escribiendo y leyendo
    Cada instancia trabaja con sus propios ficheros de datos o todas trabajan con los mismos ficheros?
    Me temo que no.

    MAQUINA 1
        mariadb-galera                      
            dato1   dato2   dato 5
    MAQUINA 2                               
        mariadb-galera                      BALANCEADOR     <   [dato1]         Clientes
            dato1   dato3   dato4
    MAQUINA 3                               
        mariadb-galera                      
            dato2   dato3
    MAQUINA 4
        mariadb-galera                      
            dato4   dato5

    Si replico el dato en todas las BBDD no hay escalabilidad
    En cuanto mejoro el rendimiento:
    Antes: Si guardo el dato en 1 máquina... o replciado en TODAS las máquinas: 1 dato por unidad de tiempo
                                                                                2 datos por 2 unidades de tiempo
    Ahora:                                                                      3 datos por 2 unidades de tiempo

        Mejora del 50% en rendimiento (teórica) pasando de 1 máquina a 3

---

Uso de memoria RAM.

Los ficheros sirven para persistencia.
Cualquier operación al final se hace en Memoria (merge, sort, union, calcular el plan de ejecución de una query)
Los datos hay que llevarlos de los ficheros a la memoria... esto a la BBDD le interesa hacerlo lo menos posible

Cuando ejecuto una query que pasa en la BBDD?
1- Análisis sintáctico del SQL
2- Validación de los datos que aparecen en la query: Existen las tablas? los campos? los tipos de datos?
3- Calcular un plan de ejecución <<<< Estadísticas, índices
4- Ejecuta el plan de ejecución

Imagina que tengo la siguiente tabla:
Productos que vendo:            fabricante (tienes un índice)
zapatillas de deporte           nike
zapatillas de deporte           nike
zapatillas de deporte           nike
zapatillas de deporte           nike
zapatillas de deporte           nike
zapatillas de deporte           nike
zapatillas de deporte           nike
zapatillas de deporte           nike
zapatillas de deporte           nike
zapatillas de deporte           nike
zapatillas de deporte           nike
zapatillas de deporte           reebok
                                ^ Se calculan estadisticas de la columna fabricante:
                                    98% de los datos son nike
                                    2% reebok

SELECT * FROM productos WHERE fabricante = "nike"
    Para esa query, usando las estadística se calcula un plan de ejecución: FULL SCAN DE LA TABLA . No usaría INDICE

SELECT * FROM productos WHERE fabricante = "rebook"
    Para esa query, usando las estadística se calcula un plan de ejecución: BUSQUEDA POR INDICE

---

Qué pasa cuando alguien abre una conexión a una BBDD a nivel de SO?
- Abrir un PROCESO !




Cliente                                              Servidor de BBDD
- proceso a nivel de SO                               - proceso a nivel de SO para la gestión de la BBDD (varios)
    Tiene su RAM                                      - cada conexión a la BBDD abre un proceso nuevo a nivel de SO ***

Abrir un proceso tiene un impacto ENORME en memoria.

Cuando queremos hacer tareas concurrentes en un SO: Qué usamos? UN HILO (Thread)
Un proceso a nivel de SO puede abrir muchos hilos!
    Pero todos esos hilos, comparten RAM... ya que la RAM va asociada al PROCESO !

Que guarda un proceso en la memoria RAM?
- El código del programa
- Datos de trabajo
- Caches

*** Y eso es imprescindible

Imaginad que un usuario hace una query, y le devuelve 1000 datos... y ahora los voy recorriendo

Y mientras tanto, otro usuario abre otra conexión y hace un insert/update/delete.
Esos datos que acaba de modificar el usuario 2, afectan a la query del usuario 1? NO

SELECT * from productos where id = 17
Zapatillas nike -> pantalla

DESPUES (0.1 seg después ha hecho):
DELETE FROM productos where id = 17;

DESPUES (0.2seg) elusuario 1 hace:

UPDATE productos set fabricante = "reebok" where id=17 -> OSTION !


DELETE * FROM PRODUCTOS;
select * from productos: 0 datos
COMMIT;

1 seg más tarde:
usuario2:
select * from productos: 1000 datos

1 seg más tarde: usuario 1
COMMIT;

1 seg más tarde:
usuario2:
select * from productos: 0 datos
---

Usuario 1: 
INSERT INTO productos (...) SELECT * from PRODUCTOS_A_IMPORTAR; ---> 1000 datos

Usuario2:
Select * from productos; -> 0

Usuario1:
Select * from productos; -> 1000

Dónde se guardando los datos que mete o borra o cambia el usuario1? En memoria... de quién? de cada proceso

LA BBDD es otro proceso que corre en la MAQUINA. Y tiene todas las tablas cargadas en memoria o parte...
Las conexiones a la BBDD abren su propio proceso... con su propia memoria, pero tienen que tener acceso a la memoria de la BBDD o a parte de ella (tablas): MEMORIA COMPARTIDA (tablas, indices, estadísticas)

Una conexión copia datos de la memoria compartida a su propia memoria RAM

Desde desarrollo, lo óptimo sería:
Un usuario hace login en el sistema: Le interesa ABRIRLE UNA CONEXIÓN A BBDD... y no liberarla hasta que haga logout.
Le interesa estar abriendo conexiones para cada query? No... tarda mucho !
Pero si nos hancen eso... en el servidor de BBDD me matan... me dejan sin memoria.
Los desarrolladores, como desde BBDD les capamos el número máximo de conexiones, montan un pool de conexiones.

Hay más zonas de memoria:
- Caches de las tablas, indices... SHARED entre BBDD y las conexiones
- Cada conexión tendrá su memoria.... que habrá que limitar
- Tenemos memoria de trabajo: Sort, merge, union -> Necesito memoria temporal donde ir dejando los datos para esas operaciones
- Operaciones de admin. Regeneración de estadísticas, índices

Al igual que esto, la BBDD también abre hilos:
- mnto: indices, estadísticas
- llevar los datos a HDD

Tendremos distintos sistemas de almacenamiento: HDD o equivalentes:
- BBDD
- Tablas
- Particiones de tablas
- Indices
- Datos temporales


Si tengo una máquina con 16 Gbs de RAM donde quiero poner una BBDD, la que sea, PG en nuestro caso, cuánta memoria le asigno? 
- Reservar para sistema operativo... 
- Cada cliente que se conecta usa memoria de SO para las comunicaciones (buffers)
- Las lecturas a fichero se hacen a través de buffers que gestiona el SO.
----

# Trabajar con contenedores

Hoy en día se ah convertido en la forma estandar de instalar software en producción

Un contenedor es un entorno AISLADO dentro de un SO con kernel Linux donde correr procesos.
Aislado:
- Tiene su propia conf. de red -> su propia IP
- Tiene su propio sistema de archivos
- Tiene sus propias variables de entorno
- Puede tener limitaciones de acceso al HW

Los contenedores los creamos desde IMAGENES de contenedor, que son ficheros comprimidos (tar)
que contienen una instalación YA REALIZADA DEL SOFTWARE.