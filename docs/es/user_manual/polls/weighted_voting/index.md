---
sections:
  introduction: d1b37bf68148b2a5
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: 9b344dddaa25f823
  set-members-vote-weights: 861ad5297b83ee45
  use-weighted-voting-in-a-poll: 067b92e9b9a01a46
  results: a545207931448c87
title: Votación ponderada
title_source: 0b971991dfcacbab
title_generated: 9c00eabb8b2b3ef6
source_revision: 3f73d4a156d9ffd3137ff085cc6ab58fbc4de46b
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-06'
---

<!-- translation-section: introduction -->

# Votación ponderada

La votación ponderada permite que algunos votos cuenten más que otros. Cada votante tiene un peso del voto. Por ejemplo:

- Una comunidad de viviendas da un voto a cada propiedad. Un miembro que representa a tres propiedades tiene un peso del voto de `3`.
- Una cooperativa de trabajo concede el derecho a votar tras un período determinado como miembro. Los miembros más recientes reciben un peso del voto de `0`, por lo que pueden contribuir a la discusión y conocer el proceso de votación sin que sus votos afecten al resultado.
- Una empresa da votos a sus accionistas según su participación en el capital. Alguien que posee el 12,5 % de las acciones tiene un peso del voto de `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Establecer los pesos del voto de los miembros

Un admin del grupo puede abrir la página **Integrantes** del grupo y seleccionar **Editar ponderaciones de voto**. Introduce los pesos del voto y selecciona **Guardar ponderaciones de voto**. Los pesos del voto pueden ser `0` o más, con hasta tres decimales. Busca por nombre o correo electrónico para encontrar a alguien. Para dar a todos los miembros el mismo peso del voto, selecciona **Establecer todos los pesos de voto**.

![Pesos del voto de los miembros del grupo](member-weights.png)

El peso del voto de un miembro se copia en cada encuesta a la que se le añade. Cambiarlo después no modifica las encuestas que ya lo tienen.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Usar votación ponderada en una encuesta

Selecciona **Usar votación ponderada** en los ajustes avanzados de la encuesta. Puedes activarla o desactivarla después de que se abra la votación. Al desactivarla, todos los pesos del voto de la encuesta pasan a ser `1` y se pierden los pesos del voto que hayas cambiado para esa encuesta.

Si tu grupo usa votación ponderada para un proceso establecido, selecciona **Usar votación ponderada** en una [plantilla de encuesta](/en/user_manual/polls/poll_templates). Las encuestas iniciadas a partir de esa plantilla usan votación ponderada.

![El ajuste Usar votación ponderada en una encuesta](poll-setting.png)

La votación ponderada funciona con estos tipos de encuesta: [Propuesta](/en/user_manual/polls/proposals), [Elegir](/en/user_manual/polls/choose), [Puntuar](/en/user_manual/polls/score), [Repartir](/en/user_manual/polls/allocate) y [Ordenar](/en/user_manual/polls/rank).

No puedes usar votación ponderada y [votación anónima](/en/user_manual/polls/anonymous_voting) en la misma encuesta.

Para cambiar el peso del voto de un votante, selecciona **Gestionar a los votantes** y luego selecciona el peso del voto junto al nombre de esa persona. Para cambiar el de todos, selecciona **Establecer todos los pesos de voto**. Puedes copiar del grupo el peso del voto de cada miembro o dar a todos el mismo valor. Los votantes que no son miembros del grupo reciben un peso del voto de `1`.

![El botón Gestionar a los votantes en una encuesta](poll-manage-voters.png)

![Votantes en una encuesta con pesos del voto individuales](poll-voter-weights.png)

<!-- translation-section: results -->

## Resultados

Los resultados muestran los totales sin ponderar y los totales ponderados uno al lado del otro:

- Las encuestas de tipo Propuesta y Elegir muestran **Votos** y **Votos ponderados**.
- Las encuestas de tipo Puntuar, Repartir y Ordenar muestran **Puntos** y **Puntos ponderados**.

El gráfico muestra el resultado ponderado. Selecciona el encabezado de una columna para mostrar esa columna en el gráfico. El recuento de votantes con derecho a votar y el quórum cuentan personas, no pesos del voto. Cualquier persona que pueda ver los votos puede ver el peso del voto de cada votante.

![El resultado de una propuesta con votos y votos ponderados](weighted-proposal-result.png)
