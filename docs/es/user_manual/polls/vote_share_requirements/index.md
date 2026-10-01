---
title: Requisitos de porcentaje de votos
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
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
  introduction: 1f8a0b614c5f6c77
  eligible-voters-and-votes-cast: 0706e1c2e264ba9b
  different-vote-share-requirements: ceb69aa9949c03a0
  detailed-example: 7002299c5e00e48d
title_source: a654891ca817844e
title_generated: 6c881bd77d508e47
---

<!-- translation-section: introduction -->

# Requisitos de porcentaje de votos

Establece un requisito de porcentaje de votos para una opción cuando una propuesta deba recibir un porcentaje determinado de apoyo, o mantenerse por debajo de un porcentaje determinado de oposición, para aprobarse.

Los requisitos de porcentaje de votos se pueden combinar con un [quórum](/en/user_manual/polls/quorum/) para exigir tanto una participación suficiente como una distribución determinada de los votos.

En el formulario de la propuesta, selecciona el icono de edición junto a una opción.

![El icono de edición junto a la opción De acuerdo](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Votantes elegibles y votos emitidos

El porcentaje puede basarse en los **Votos emitidos** o en los **votantes elegibles**.

![Elección entre votos emitidos y votantes elegibles como base de un requisito de porcentaje de votos](./eligible-vs-cast.png)

**votantes elegibles** se refiere a todas las personas que pueden votar en la propuesta. **Votos emitidos** se refiere únicamente a los votos que se han enviado.

Un requisito de un 75 por ciento de acuerdo entre los votantes elegibles solo se cumple cuando al menos el 75 por ciento de todos los votantes elegibles vota por esa opción.

Un requisito de un 60 por ciento de acuerdo entre los votos emitidos se cumple cuando el 60 por ciento de los votos enviados apoya la opción, independientemente de la participación total. Añade un quórum cuando tu proceso también requiera un nivel mínimo de participación.

<!-- translation-section: different-vote-share-requirements -->

## Distintos requisitos de porcentaje de votos

Una propuesta puede tener requisitos para más de una opción. Por ejemplo:

- De acuerdo debe representar al menos el 75 por ciento de los votantes elegibles
- Abstención debe representar como máximo el 30 por ciento de los votos emitidos
- Bloqueo debe representar como máximo el 0 por ciento de los votos emitidos

Establecer una opción en **Como máximo un 0%** es una práctica habitual. Significa que la propuesta no puede aprobarse si alguien elige esa opción. Úsalo en **Bloquear** para que un solo bloqueo detenga la propuesta.

También puedes añadir requisitos a una [plantilla de encuesta](/en/user_manual/polls/poll_templates/) para que las nuevas propuestas creadas a partir de la plantilla los usen de forma predeterminada.

<!-- translation-section: detailed-example -->

## Ejemplo detallado

La cooperativa Oatmilk está decidiendo si realizar una prueba de seis semanas con botellas retornables. Cinco personas pueden votar.

El proceso de la cooperativa requiere que al menos el 75 por ciento de los votantes elegibles esté de acuerdo. Jamie edita la opción **De acuerdo** de la propuesta, activa el requisito de porcentaje de votos y lo establece en **Al menos el 75% de los votantes elegibles**.

![La opción De acuerdo requiere al menos el 75 por ciento de los votantes elegibles](./agree-vote-option.png)

Jamie también establece un quórum del 60 por ciento. Jamie y Samira votan De acuerdo. Todos los votos enviados apoyan la propuesta, pero representan solo el 40 por ciento de los votantes elegibles, por lo que no se ha cumplido ninguno de los dos requisitos.

![Dos de las cinco personas han votado De acuerdo y no se ha cumplido ninguno de los dos requisitos](./first-vote-breakdown.png)

Después, Alex y Morgan votan De acuerdo, mientras que Taylor vota En desacuerdo. Las cinco personas han votado, con lo que se alcanza el quórum, y cuatro de los cinco votantes elegibles están de acuerdo. El 80 por ciento de acuerdo supera el requisito de porcentaje de votos del 75 por ciento, por lo que ambos requisitos muestran marcas de verificación verdes.

![Las cinco personas han votado y se han cumplido ambos requisitos](./final-vote-breakdown.png)
