---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: 6230a7dfc46996f7
  set-members-vote-weights: aa2f08eb2a3efc20
  use-weighted-voting-in-a-poll: e237eded3ef6934b
  results: 4bcea2a748a7f415
title: Votación ponderada
title_source: 0b971991dfcacbab
title_generated: 9c00eabb8b2b3ef6
source_revision: 3a315412c646d254c8426be5c436a4e593f6011f
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# Votación ponderada

La votación ponderada permite que algunos votos cuenten más que otros. Cada votante tiene un peso de voto. Por ejemplo:

- Una comunidad de viviendas asigna un voto a cada propiedad. Un integrante que representa a tres propiedades tiene un peso de voto de `3`.
- El consejo de administración de una cooperativa toma la decisión, pero el personal de operaciones participa en la conversación. Los integrantes del consejo tienen un peso de voto de `1`. El personal de operaciones tiene un peso de voto de `0`, por lo que sus votos se registran, pero no cambian el resultado.
- Una empresa asigna votos a los accionistas según su participación en el capital. Una persona que posee el 12,5 % de las acciones tiene un peso de voto de `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Establecer los pesos de voto de los integrantes

Un administrador del grupo puede abrir la página **Integrantes** del grupo y seleccionar **Editar ponderaciones de voto**. Introduce los pesos de voto y selecciona **Guardar ponderaciones de voto**. Los pesos de voto pueden ser `0` o más, con hasta tres decimales. Busca por nombre o correo electrónico para encontrar a alguien. Para asignar el mismo peso de voto a todos los integrantes, selecciona **Establecer todos los pesos de voto**.

![Pesos de voto de los integrantes del grupo](member-weights.png)

El peso de voto de cada integrante se copia en cada encuesta a la que se añade. Cambiarlo después no modifica las encuestas que ya tienen ese peso de voto.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Usar votación ponderada en una encuesta

Selecciona **Usar votación ponderada** en la configuración avanzada de la encuesta. Puedes activar o desactivar esta opción después de que se abra la votación. Al desactivarla, todos los pesos de voto de la encuesta se establecen en `1` y se pierden los pesos de voto que hayas modificado para esa encuesta.

Si tu grupo usa votación ponderada para un proceso establecido, selecciona **Usar votación ponderada** en una [plantilla de encuesta](/en/user_manual/polls/poll_templates). Las encuestas iniciadas a partir de esa plantilla usan votación ponderada.

![La opción Usar votación ponderada en una encuesta](poll-setting.png)

La votación ponderada funciona con estos tipos de encuesta: [Propuesta](/en/user_manual/polls/proposals), [Elegir](/en/user_manual/polls/choose), [Puntaje](/en/user_manual/polls/score), [Asignar](/en/user_manual/polls/allocate) y [Rango](/en/user_manual/polls/rank).

No puedes usar votación ponderada y [votación anónima](/en/user_manual/polls/anonymous_voting) en la misma encuesta.

Para cambiar el peso de voto de un votante, selecciona **Gestionar a los votantes** y luego selecciona el peso de voto junto al nombre del votante. Para cambiar los pesos de todos, selecciona **Establecer todos los pesos de voto**. Puedes copiar del grupo el peso de voto de cada integrante o asignar el mismo valor a todos. Los votantes que no son integrantes del grupo reciben un peso de voto de `1`.

![El botón Gestionar a los votantes en una encuesta](poll-manage-voters.png)

![Votantes de una encuesta con pesos de voto individuales](poll-voter-weights.png)

<!-- translation-section: results -->

## Resultados

Los resultados muestran los totales sin ponderar y los totales ponderados uno al lado del otro:

- Las encuestas de Propuesta y Elegir muestran **Votos** y **Votos ponderados**.
- Las encuestas de Puntaje, Asignar y Rango muestran **Puntos** y **Puntos ponderados**.

El gráfico muestra el resultado ponderado. Selecciona el encabezado de una columna para mostrar esa columna en el gráfico. El recuento de votantes habilitados y el quórum cuentan personas, no pesos de voto. Cualquier persona que pueda ver los votos puede ver el peso de voto de cada votante.

![Resultado de una propuesta con votos y votos ponderados](weighted-proposal-result.png)
