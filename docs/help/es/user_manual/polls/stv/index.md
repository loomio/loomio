---
title: Elecciones STV
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
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
  introduction: 9810a117bfd928a0
  when-to-use-stv: cba880a8e6647d60
  creating-an-stv-election: 5344baeb0f4abd0d
  number-of-seats: 9b1b860f7d73bfaf
  counting-method: 30fc98e027c8b30b
  quota-type: da8b443cabe967d6
  how-voting-works: 2018907cea7b34cd
  how-counting-works: b3743a48a8770150
  understanding-results: bb0fa955bd9c98a0
  method-and-quota: f4958531186ad98f
  elected-candidates: a60183a7463555c1
  round-by-round-details: ea0d04a4e87eba29
  exporting-ballots: fc777d2fb850f764
  share-an-outcome: f6d9c30671fdfbc1
title_source: cd3e1a4cdc2456a6
title_generated: ac82e1e9db982f29
---

<!-- translation-section: introduction -->

# Elecciones STV

El **voto único transferible (STV)** es un método de votación de representación proporcional para elegir a varios ganadores entre un conjunto de candidatos. Garantiza que los candidatos elegidos representen proporcionalmente la diversidad de opiniones de los votantes.

<!-- translation-section: when-to-use-stv -->

## Cuándo usar STV

Usa una elección STV cuando necesites:

- Elegir un **comité, una junta o un conjunto de delegados** entre las personas propuestas
- Garantizar la **representación proporcional**, para que los sectores minoritarios puedan obtener puestos en proporción al apoyo que reciben
- Organizar elecciones en las que los votantes ordenen a los candidatos por preferencia

>[!NOTE]
>STV **no** es lo mismo que la [encuesta de votación preferencial](/en/user_manual/polls/rank/) de Loomio, que utiliza una clasificación más sencilla basada en puntuaciones para elegir una única opción como la mejor. STV permite elegir a varios ganadores mediante transferencias de votos y rondas de eliminación.

<!-- translation-section: creating-an-stv-election -->

## Crear una elección STV

Al iniciar una encuesta, selecciona **Elecciones STV** como tipo de encuesta y añade los candidatos como opciones. Puedes personalizar la encuesta configurando el **número de puestos**, el **método de recuento** y el **tipo de cuota**.

En este ejemplo, Oatmilk Cooperative elige a tres personas para supervisar su prueba de envases retornables. El formulario explica la función, enumera cinco candidatos y utiliza STV escocés con la cuota Droop.

![](form.png)

<!-- translation-section: number-of-seats -->

### Número de puestos

Cuántos ganadores se deben elegir. Debe ser menor que el número de candidatos.

<!-- translation-section: counting-method -->

### Método de recuento

Hay dos métodos disponibles para contar los votos:

STV escocés
  : Recomendado. El método Gregory inclusivo ponderado (WIGM), utilizado en las elecciones locales escocesas desde 2007. Tiene reglas claras y bien definidas. Es el más adecuado para la mayoría de las organizaciones.
  
STV Meek
  : Un método más preciso cuyo recuento solo puede realizar un ordenador. Cuando un candidato resulta elegido, Meek sigue transfiriendo la parte de cada voto que no necesita a las preferencias posteriores del votante, incluidos los votos que recibe más adelante en el recuento. Cuando un candidato queda eliminado, los votos se vuelven a contar como si ese candidato nunca se hubiera presentado. Se desperdician menos votos que con STV escocés, pero el recuento no se puede comprobar a mano.

<!-- translation-section: quota-type -->

### Tipo de cuota

La cuota es el número mínimo de votos que necesita un candidato para obtener un puesto. Puede ser una de las siguientes:

Droop
  : Recomendada. La cuota estándar para las elecciones STV, utilizada en Irlanda, Australia y Escocia. Es la cuota más pequeña que impide que la alcancen más candidatos que puestos disponibles. Un grupo de votantes que sitúa a sus propios candidatos en primer lugar obtiene al menos tantos puestos como cuotas suman sus votos. Se calcula así:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Una cuota mayor. Los grupos con muchos votos utilizan más votos por cada puesto que obtienen, por lo que los grupos más pequeños tienen más probabilidades de obtener los últimos puestos. Se calcula así:
    \\[ \frac{votes}{seats}\\]

En ambas fórmulas, *votes* es el número de papeletas que incluyen al menos un candidato en el orden de preferencias.

STV Meek calcula la cuota sin redondear, como votes ÷ (seats + 1) para Droop. Recalcula la cuota en cada ronda a partir de los votos que aún tienen los candidatos, y un candidato debe superarla para resultar elegido.
  
  >[!TIP]
  > La cuota Droop siempre da un número de votos menor que la cuota Hare. Por ejemplo, en una elección con 100 votos y cuatro puestos, la cuota Droop sería 21 y la cuota Hare, 25.

<!-- translation-section: how-voting-works -->

## Cómo funciona la votación

En este ejemplo, Oatmilk Cooperative elige a tres personas para supervisar la prueba de envases reutilizables. Los votantes arrastran a los candidatos por encima de la línea y los ordenan por preferencia:

![](stv-vote-in-progress.png)

- **Preferencia 1** = candidato preferido
- **Preferencia 2** = segunda opción
- Continúa ordenando tantos candidatos como quieras

Los votantes deben ordenar al menos un candidato, pero no necesitan ordenarlos todos. Los candidatos que no incluyan en su orden de preferencias no recibirán ningún apoyo de ese votante.

<!-- translation-section: how-counting-works -->

## Cómo funciona el recuento
El recuento se realiza así:

1. Se calcula una **cuota** (el mínimo de votos necesarios para obtener un puesto).
2. Se cuentan las **Primeras preferencias** de cada candidato.
3. Cada candidato que alcanza la cuota resulta **elegido**. Sus votos excedentes (por encima de la cuota) se **transfieren** a las siguientes preferencias de los votantes con un valor fraccionario, empezando por el mayor excedente. Los votos solo se transfieren a candidatos que siguen en el recuento.
4. Si no queda ningún excedente por transferir, **se elimina al candidato con menos votos**. Sus votos se transfieren a las siguientes preferencias de los votantes con su valor completo.
5. Cuando el número de candidatos restantes es igual al número de puestos restantes, todos resultan elegidos, aunque no hayan alcanzado la cuota.
6. En caso contrario, el recuento se repite desde el paso 3 hasta cubrir todos los puestos.

El valor fraccionario reparte solo los votos que un ganador no necesita. Por ejemplo, si la cuota es 26 y un candidato tiene 40 votos, su excedente es 14. Cada una de sus 40 papeletas pasa a la siguiente preferencia con un valor de 14 ÷ 40 = 0.35 de un voto.

En STV escocés, el valor de cada voto transferido se redondea hacia abajo a cinco decimales, como en las elecciones municipales escocesas.

Si dos o más candidatos empatan con el menor número de votos, se elimina al que tenía menos votos en la ronda anterior más reciente en la que sus recuentos diferían.

>[!TIP]
>Una papeleta solo cuenta mientras incluya en su orden de preferencias a un candidato que siga en el recuento. Cuando no queda ninguno, la papeleta se considera «agotada» y deja de contar.

<!-- translation-section: understanding-results -->

## Entender los resultados

Cuando se cierra la encuesta, los resultados se muestran en varias secciones. En esta elección, Samira Patel, Alex Morgan y Morgan Price ocupan los tres puestos del comité:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Método y cuota

En la parte superior verás el método de recuento (STV escocés o STV Meek) y el tipo de cuota (Droop o Hare), junto con la cuota: el número de votos que necesitaba un candidato para obtener un puesto.

<!-- translation-section: elected-candidates -->

### Candidatos elegidos

Una tabla de resumen de los ganadores con cinco columnas:

| Columna | Significado |
|--------|---------|
| **Candidato** | El nombre del candidato elegido |
| **Ronda elegida** | La ronda del recuento en la que alcanzó la cuota y obtuvo un puesto. La ronda 1 significa que ganó solo con las primeras preferencias; las rondas posteriores significan que necesitó votos transferidos de candidatos eliminados o con excedentes. |
| **Primeras preferencias** | Cuántos votantes situaron a este candidato como su primera opción. Muestra el apoyo directo de un candidato antes de cualquier transferencia de votos. |
| **Recuento final** | El recuento de votos del candidato en el momento en que resultó elegido. Debido a las transferencias de votos, suele ser mayor que sus primeras preferencias. |
| **Superávit** | Cuánto superó la cuota el recuento final del candidato (recuento final menos cuota). Un superávit mayor indica más apoyo por encima del necesario para ganar. En STV escocés, este superávit se redistribuye a las siguientes preferencias de los votantes. |

A veces las rondas anteriores no permiten resolver un empate. Si el empate no cambia quién resulta elegido, el recuento continúa. Si lo cambia, el recuento se detiene en esa ronda. Los candidatos que ganan independientemente de cómo se resuelva el empate aparecen como elegidos. Los candidatos que podrían ganar o perder según cómo se resuelva el empate aparecen en una tabla aparte. Loomio los muestra como empatados en lugar de elegir a uno al azar.

<!-- translation-section: round-by-round-details -->

### Detalles ronda por ronda

Despliega **Detalles ronda por ronda** para ver las transferencias de votos y las eliminaciones. Cada fila corresponde a un candidato y cada columna a una ronda del recuento. Cada número indica los votos que tenía el candidato al inicio de esa ronda:

![](stv-results.png)

El resaltado verde indica cuándo resultó elegido un candidato, el rojo cuándo quedó eliminado y el naranja cuándo empató.

<!-- translation-section: share-an-outcome -->

## Comparte una conclusión

Cuando se cierre la elección, comparte una conclusión. Nombra a las personas elegidas e indica cuándo empieza su función. Consulta [Comparte una conclusión](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) para saber cómo funcionan las conclusiones.

![Una conclusión que nombra a los miembros elegidos del comité](outcome.png)

<!-- translation-section: exporting-ballots -->

## Exportar papeletas

Cuando se cierre la elección, las personas que pueden ver los resultados podrán exportar las papeletas en formato BLT para realizar un recuento independiente o una auditoría. La exportación contiene las clasificaciones de los candidatos por orden de preferencia y agrupa las clasificaciones idénticas en una sola fila con el número de papeletas. En las elecciones anónimas, no contiene identidades de votantes, identificadores de papeletas, horas de envío ni orden de envío.
