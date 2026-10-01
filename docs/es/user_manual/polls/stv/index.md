---
title: Elecciones STV
source_revision: cf8da02f691349beecf6ac6444971fad130d4ddd
source_file: docs/en/user_manual/polls/stv/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 6c43a75f60922bb6
  when-to-use-stv: e37de389c27f7d87
  creating-an-stv-election: 2d475191d922803f
  number-of-seats: 9463d911f230eea0
  counting-method: b7ff2dce779d15c1
  quota-type: f9ab31d93916bf24
  how-voting-works: bace7c735dbb39f1
  how-counting-works: 794084f981b2cf3f
  understanding-results: 8442813a9c097112
  method-and-quota: 90113296c3d59816
  elected-candidates: 7ac0bae756fa5608
  round-by-round-details: c0ccc83e51dcaa1a
  exporting-ballots: 582555dd13633bf0
  share-an-outcome: 6a02aed173b368b9
generated:
  introduction: 70e9f35e136dffe9
  when-to-use-stv: d14416ac0339a981
  creating-an-stv-election: 0e8ce30388f37acb
  number-of-seats: b3777fc6c55cac94
  counting-method: 0576e40955fc06dc
  quota-type: 0da74951a103f74e
  how-voting-works: 5439adc9c06e171a
  how-counting-works: 8e1d0eac7b6d1733
  understanding-results: 64b2fb5616b916c7
  method-and-quota: 4ad11e2b8165ccbf
  elected-candidates: e39bed5aa493b376
  round-by-round-details: 87fd96e14cf50da7
  exporting-ballots: 30b0842ed47ecd50
  share-an-outcome: 909473612128bfc0
title_source: cd3e1a4cdc2456a6
title_generated: ac82e1e9db982f29
---

<!-- translation-section: introduction -->

# Elecciones STV

El **voto único transferible (STV)** es un método de representación proporcional para elegir a varias personas entre un grupo de candidatos. Permite que las personas elegidas representen proporcionalmente la diversidad de opiniones de quienes votan.

<!-- translation-section: when-to-use-stv -->

## Cuándo usar STV

Usa una elección STV cuando necesites:

- Elegir un **comité, una junta o un grupo de delegados** entre varias candidaturas
- Garantizar la **representación proporcional**, de modo que los grupos minoritarios puedan obtener escaños según el apoyo que reciban
- Celebrar elecciones en las que quienes votan ordenen a los candidatos por preferencia

>[!NOTE]
>STV **no** es lo mismo que el [sondeo de clasificación](/en/user_manual/polls/rank/) de Loomio, que usa puntuaciones para elegir una única opción. STV permite elegir a varias personas mediante transferencias de votos y rondas de eliminación.

<!-- translation-section: creating-an-stv-election -->

## Crear una elección STV

Al iniciar un sondeo, selecciona **Elecciones STV** como tipo de sondeo y añade a los candidatos como opciones. Puedes configurar el **número de escaños**, el **método de recuento** y el **tipo de cuota**.

En este ejemplo, la Cooperativa Oatmilk elige a tres personas para supervisar una prueba de envases retornables. El formulario explica la función, enumera a cinco candidatos y utiliza el método STV escocés con la cuota Droop.

![](form.png)

<!-- translation-section: number-of-seats -->

### Número de escaños

Es el número de personas que se elegirán. Debe ser menor que el número de candidatos.

<!-- translation-section: counting-method -->

### Método de recuento

Hay dos métodos disponibles para contar los votos:

Scottish STV
  : Recomendado. Utiliza el método Gregory inclusivo ponderado (WIGM), empleado en las elecciones locales de Escocia desde 2007. Tiene reglas claras y sencillas. Es la mejor opción para la mayoría de las organizaciones.
  
Meek STV
  : Un método más preciso cuyo recuento solo puede realizar una computadora. Cuando se elige a un candidato, Meek sigue transfiriendo la parte de cada voto que no necesita a las siguientes preferencias de quien votó, incluidos los votos que recibe más adelante en el recuento. Cuando se elimina a un candidato, los votos se vuelven a contar como si nunca hubiera participado. Se desperdician menos votos que con Scottish STV, pero el recuento no se puede comprobar a mano.

<!-- translation-section: quota-type -->

### Tipo de cuota

La cuota es el número mínimo de votos que necesita un candidato para obtener un escaño. Hay dos opciones:

Droop
  : Recomendada. Es la cuota habitual en las elecciones STV y se utiliza en Irlanda, Australia y Escocia. Es la cuota más pequeña que impide que la alcancen más candidatos que escaños disponibles. Un grupo de votantes que coloca a sus propios candidatos en primer lugar obtiene al menos tantos escaños como cuotas sumen sus votos. Se calcula así:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Una cuota más alta. Los grupos con muchos votos utilizan más de ellos en cada escaño que obtienen, por lo que los grupos más pequeños tienen más probabilidades de obtener los últimos escaños. Se calcula así:
    \\[ \frac{votes}{seats}\\]

En ambas fórmulas, *votes* es el número de papeletas que incluyen al menos un candidato en el orden de preferencias.

Meek STV calcula la cuota sin redondear: para Droop, es votes ÷ (seats + 1). Recalcula la cuota en cada ronda a partir de los votos que aún tienen los candidatos, y un candidato debe superarla para resultar elegido.
  
  >[!TIP]
  > La cuota Droop siempre requiere menos votos que la cuota Hare. Por ejemplo, en una elección con 100 votos y cuatro escaños, la cuota Droop sería 21 y la cuota Hare, 25.

<!-- translation-section: how-voting-works -->

## Cómo se vota

En este ejemplo, la Cooperativa Oatmilk elige a tres personas para supervisar la prueba de envases reutilizables. Quienes votan arrastran a los candidatos por encima de la línea y los ordenan según sus preferencias:

![](stv-vote-in-progress.png)

- **Puesto 1** = candidato preferido
- **Puesto 2** = segunda opción
- Sigue ordenando tantos candidatos como quieras

Quienes votan deben ordenar al menos a un candidato, pero no es obligatorio ordenar a todos. Los candidatos que no se incluyan no recibirán ningún apoyo de ese voto.

<!-- translation-section: how-counting-works -->

## Cómo funciona el recuento
El recuento sigue estos pasos:

1. Se calcula una **cuota** (el número mínimo de votos necesario para obtener un escaño).
2. Se cuentan las **Primeras preferencias** de cada candidato.
3. Todos los candidatos que alcanzan la cuota resultan **elegidos**. Sus votos excedentes (por encima de la cuota) se **transfieren** a las siguientes preferencias de quienes votaron por ellos, con un valor fraccionario, empezando por el mayor excedente. Los votos solo se transfieren a candidatos que siguen en el recuento.
4. Si no quedan excedentes por transferir, se **elimina al candidato con menos votos**. Sus votos se transfieren a las siguientes preferencias con su valor completo.
5. Cuando el número de candidatos restantes es igual al de escaños por cubrir, todos resultan elegidos, aunque no hayan alcanzado la cuota.
6. En caso contrario, el recuento se repite desde el paso 3 hasta cubrir todos los escaños.

El valor fraccionario permite repartir únicamente los votos que una persona elegida no necesita. Por ejemplo, si la cuota es 26 y un candidato tiene 40 votos, su excedente es 14. Cada una de sus 40 papeletas pasa a la siguiente preferencia con un valor de 14 ÷ 40 = 0.35 de un voto.

En Scottish STV, el valor de cada voto transferido se redondea hacia abajo a cinco decimales, como en las elecciones municipales de Escocia.

Si dos o más candidatos empatan con el menor número de votos, se elimina al que tenía menos votos en la ronda anterior más reciente que permita resolver el empate.

>[!TIP]
>Una papeleta solo cuenta mientras incluya en su orden de preferencias a un candidato que siga en el recuento. Cuando no queda ninguno, la papeleta se considera «agotada» y deja de contar.

<!-- translation-section: understanding-results -->

## Entender los resultados

Cuando se cierra el sondeo, los resultados aparecen en varias secciones. En esta elección, Samira Patel, Alex Morgan y Morgan Price ocupan los tres puestos del comité:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Método y cuota

En la parte superior verás el método de recuento (STV escocés o STV de Meek), el tipo de cuota (Droop o Hare) y la cuota: el número de votos que necesitaba un candidato para obtener un escaño.

<!-- translation-section: elected-candidates -->

### Candidatos elegidos

Una tabla resume los resultados de las personas elegidas en cinco columnas:

| Columna | Significado |
|--------|---------|
| **Candidato** | El nombre del candidato elegido |
| **Ronda elegida** | La ronda de recuento en la que alcanzó la cuota y obtuvo un escaño. La ronda 1 indica que ganó solo con las primeras preferencias; las rondas posteriores indican que necesitó votos transferidos de candidatos eliminados o de los excedentes de otros candidatos. |
| **Primeras preferencias** | El número de personas que eligieron a este candidato como primera opción. Muestra su apoyo directo antes de cualquier transferencia de votos. |
| **Recuento final** | Los votos que tenía el candidato cuando resultó elegido. Debido a las transferencias, esta cifra suele ser mayor que sus primeras preferencias. |
| **Superávit** | La cantidad en que el recuento final superó la cuota (recuento final menos cuota). Un superávit mayor indica más apoyo del necesario para ganar. En Scottish STV, se redistribuye entre las siguientes preferencias de quienes votaron por el candidato. |

A veces, las rondas anteriores no permiten resolver un empate. Si el empate no cambia quién resulta elegido, el recuento continúa. Si lo cambia, el recuento se detiene en esa ronda. Los candidatos que ganan independientemente de cómo se resuelva el empate aparecen como elegidos. Los candidatos que podrían ganar o perder según cómo se resuelva aparecen en una tabla aparte. Loomio los muestra como empatados en lugar de elegir a uno al azar.

<!-- translation-section: round-by-round-details -->

### Detalles ronda por ronda

Despliega **Detalles ronda por ronda** para ver las transferencias de votos y las eliminaciones. Cada fila corresponde a un candidato y cada columna, a una ronda de recuento. Cada número indica los votos que tenía el candidato al inicio de esa ronda:

![](stv-results.png)

El color verde indica cuándo se eligió a un candidato; el rojo, cuándo se eliminó; y el naranja, cuándo hubo un empate.

<!-- translation-section: share-an-outcome -->

## Comparte una conclusión

Cuando se cierre la elección, comparte una conclusión. Nombra a las personas elegidas e indica cuándo comenzarán a ejercer sus funciones. Consulta [Comparte una conclusión](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) para saber cómo funcionan las conclusiones.

![Una conclusión que nombra a las personas elegidas para el comité](outcome.png)

<!-- translation-section: exporting-ballots -->

## Exportar papeletas

Cuando se cierra la elección, las personas que pueden ver los resultados pueden exportar las papeletas en formato BLT para hacer un recuento o una auditoría independientes. La exportación contiene las preferencias de candidatos y agrupa las papeletas con el mismo orden en una sola fila con su cantidad. En las elecciones anónimas, no incluye la identidad de quienes votaron, identificadores de las papeletas, horas de envío ni el orden en que se enviaron.
