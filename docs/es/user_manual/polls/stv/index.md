---
title: Elecciones STV
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/stv/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 6c43a75f60922bb6
  when-to-use-stv: e37de389c27f7d87
  creating-an-stv-election: 2d475191d922803f
  number-of-seats: 9463d911f230eea0
  counting-method: 31e83bb5bc08829c
  quota-type: 12d5c4b5fe2abb1d
  how-voting-works: b9a7df3cedbe4d50
  how-counting-works: 50ba0a7800bc5667
  understanding-results: 8442813a9c097112
  method-and-quota: 90113296c3d59816
  elected-candidates: a6c3dbb5548c7d41
  round-by-round-details: e4a8789dae29d49e
  exporting-ballots: 582555dd13633bf0
generated:
  introduction: 70e9f35e136dffe9
  when-to-use-stv: d14416ac0339a981
  creating-an-stv-election: 0e8ce30388f37acb
  number-of-seats: b3777fc6c55cac94
  counting-method: 10e581f40e79ee92
  quota-type: 710dc5a356bd7142
  how-voting-works: 1d05a1f1fd51878c
  how-counting-works: 6765d60b826439c9
  understanding-results: 64b2fb5616b916c7
  method-and-quota: 4ad11e2b8165ccbf
  elected-candidates: 42459c7ce6941e28
  round-by-round-details: cf0350cfe8cce26e
  exporting-ballots: 30b0842ed47ecd50
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

STV escocés : Recomendado. Utiliza el método Gregory inclusivo ponderado (WIGM), empleado en las elecciones locales de Escocia desde 2007. Tiene reglas claras y sencillas. Es la mejor opción para la mayoría de las organizaciones.

STV de Meek : Es un método iterativo más preciso desde el punto de vista matemático. Cuando se elimina a un candidato, los votos se vuelven a contar como si nunca hubiera participado.

<!-- translation-section: quota-type -->

### Tipo de cuota

La cuota es el número mínimo de votos que necesita un candidato para obtener un escaño. Hay dos opciones:

Droop : Recomendada. Es la cuota habitual en la mayoría de las elecciones STV y se utiliza en Irlanda, Australia y Escocia. Droop garantiza que una coalición con la mayoría de los votos obtenga la mayoría de los escaños. Se calcula así: \\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Establece un umbral mínimo más alto y ofrece mayor proporcionalidad a los grupos pequeños.
    Las agrupaciones de DSA prefieren Hare para proteger la representación de las minorías.
   Se calcula así:
    \\[ \frac{votes}{seats}\\]

>[!TIP]
  > La cuota Droop siempre requiere menos votos que la cuota Hare. Por ejemplo, en una elección con 100 votos y cuatro escaños, la cuota Droop sería 21 y la cuota Hare, 25.

<!-- translation-section: how-voting-works -->

## Cómo se vota

En este ejemplo, la Cooperativa Oatmilk elige a tres personas para supervisar la prueba de envases reutilizables. Quienes votan arrastran a los candidatos por encima de la línea y los ordenan según sus preferencias:

![](stv-vote-in-progress.png)

- **Puesto 1** = candidato preferido
- **Puesto 2** = segunda opción
- Sigue ordenando tantos candidatos como quieras

No es obligatorio ordenar a todos los candidatos. Los candidatos que no se incluyan no recibirán ningún apoyo de ese voto.

<!-- translation-section: how-counting-works -->

## Cómo funciona el recuento
El recuento sigue estos pasos:

1. Se calcula una **cuota** (el número mínimo de votos necesario para obtener un escaño).
2. Se cuentan las **Primeras preferencias** de cada candidato.
3. Si un candidato alcanza la cuota, resulta **elegido**. Sus votos excedentes (por encima de la cuota) se **transfieren** a las siguientes preferencias de quienes votaron por él, con un valor fraccionario.
4. Si ningún candidato alcanza la cuota, se **elimina al candidato con menos votos**. Sus votos se transfieren a las siguientes preferencias con su valor completo.
5. El proceso se repite hasta cubrir todos los escaños.

>[!TIP]
>Si un voto no incluye a ninguno de los candidatos que quedan, se considera «agotado» y deja de contar. Por eso, suele ser mejor ordenar a más candidatos.

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
| **Ronda elegida** | La ronda de recuento en la que alcanzó la cuota y obtuvo un escaño. La ronda 1 indica que ganó solo con las primeras preferencias; las rondas posteriores indican que necesitó votos transferidos de candidatos eliminados o de sus excedentes. |
| **Primeras preferencias** | El número de personas que eligieron a este candidato como primera opción. Muestra su apoyo directo antes de cualquier transferencia de votos. |
| **Recuento final** | Los votos que tenía el candidato cuando resultó elegido. Debido a las transferencias, esta cifra suele ser mayor que sus primeras preferencias. |
| **Superávit** | La cantidad en que el recuento final superó la cuota (recuento final menos cuota). Un superávit mayor indica más apoyo del necesario para ganar. En el STV escocés, se redistribuye entre las siguientes preferencias de quienes votaron por el candidato. |

Si el recuento termina en empate y eliminar a cualquiera de los candidatos restantes cambiaría el resultado, esos candidatos aparecen en una tabla aparte en lugar de elegir arbitrariamente a uno de ellos.

<!-- translation-section: round-by-round-details -->

### Detalles ronda por ronda

Despliega **Detalles ronda por ronda** para ver las transferencias de votos y las eliminaciones. Cada fila corresponde a un candidato y cada columna, a una ronda de recuento:

![](stv-results.png)

El color verde indica cuándo se eligió a un candidato; el rojo, cuándo se eliminó; y el naranja, cuándo hubo un empate.

<!-- translation-section: exporting-ballots -->

## Exportar papeletas

Cuando se cierra la elección, las personas que pueden ver los resultados pueden exportar las papeletas en formato BLT para hacer un recuento o una auditoría independientes. La exportación contiene las preferencias de candidatos y agrupa las papeletas con el mismo orden en una sola fila con su cantidad. En las elecciones anónimas, no incluye la identidad de quienes votaron, identificadores de las papeletas, horas de envío ni el orden en que se enviaron.
