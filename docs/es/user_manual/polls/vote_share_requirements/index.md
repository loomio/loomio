---
title: Requisitos de porcentaje de votos
source_revision: 3a315412c646d254c8426be5c436a4e593f6011f
source_file: docs/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 57d7127721bebf93
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: cfdfd13a0a6a8b38
  detailed-example: 395dbccb0e6427fc
generated:
  introduction: 464405d6abfe8738
  eligible-voters-and-votes-cast: 7dc48f7557c99413
  different-vote-share-requirements: 62f8d433f3035995
  detailed-example: 19ce4188abbc74cd
title_source: a654891ca817844e
title_generated: 6c881bd77d508e47
---

<!-- translation-section: introduction -->

# Requisitos de porcentaje de votos

Establece un porcentaje de votos requerido para una opción cuando una propuesta necesita alcanzar un porcentaje determinado de apoyo, o mantenerse por debajo de un porcentaje determinado de oposición, para aprobarse.

Puedes combinar los requisitos de porcentaje de votos con un [cuórum](/en/user_manual/polls/quorum/) para exigir tanto una participación suficiente como una distribución determinada de los votos.

En el formulario de la propuesta, selecciona el icono de edición junto a una opción.

![El icono de edición junto a la opción De acuerdo](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Votantes elegibles y votos emitidos

El porcentaje puede calcularse sobre los **Votos emitidos** o los **votantes elegibles**.

![Elección de votos emitidos o votantes elegibles para calcular el porcentaje requerido](./eligible-vs-cast.png)

**votantes elegibles** son todas las personas que pueden votar en la propuesta. **Votos emitidos** son únicamente los votos que se han enviado.

Un requisito del 75 % de apoyo entre los votantes elegibles solo se cumple si al menos el 75 % de todas las personas elegibles vota por esa opción.

Un requisito del 60 % de apoyo entre los votos emitidos se cumple si el 60 % de los votos enviados apoya la opción, independientemente de la participación total. Añade un cuórum si tu proceso también exige un nivel mínimo de participación.

<!-- translation-section: different-vote-share-requirements -->

## Distintos requisitos de porcentaje de votos

Una propuesta puede tener requisitos en más de una opción. Por ejemplo:

- El apoyo debe alcanzar al menos el 75 % de los votantes elegibles
- La abstención no debe superar el 30 % de los votos emitidos
- El bloqueo no debe superar el 0 % de los votos emitidos

Establecer una opción en **No más que 0 %** es una práctica habitual. Significa que la propuesta no puede aprobarse si alguien elige esa opción. Usa este requisito en **Bloquear** para que un solo bloqueo impida que la propuesta se apruebe.

También puedes añadir requisitos a una [plantilla de encuesta](/en/user_manual/polls/poll_templates/) para que las nuevas propuestas creadas a partir de ella los utilicen de forma predeterminada.

<!-- translation-section: detailed-example -->

## Ejemplo detallado

La cooperativa Oatmilk está decidiendo si realiza una prueba de seis semanas con botellas retornables. Cinco personas pueden votar.

El proceso de la cooperativa exige el apoyo de al menos el 75 % de los votantes elegibles. Jamie edita la opción **De acuerdo** de la propuesta, activa su requisito de porcentaje de votos y lo establece en **Al menos el 75 % de los votantes elegibles**.

![La opción De acuerdo exige el apoyo de al menos el 75 % de los votantes elegibles](./agree-vote-option.png)

Jamie también establece un cuórum del 60 %. Jamie y Samira votan a favor. Todos los votos emitidos apoyan la propuesta, pero representan solo el 40 % de los votantes elegibles. Por eso, aún no se cumple ninguno de los dos requisitos.

![Dos de las cinco personas han votado a favor y no se cumple ninguno de los requisitos](./first-vote-breakdown.png)

Después, Alex y Morgan votan a favor, mientras que Taylor vota en contra. Las cinco personas han votado, por lo que se alcanza el cuórum, y cuatro de las cinco personas elegibles apoyan la propuesta. El 80 % de apoyo supera el requisito del 75 %, así que ambos requisitos muestran marcas verdes de verificación.

![Las cinco personas han votado y se cumplen ambos requisitos](./final-vote-breakdown.png)
