---
title: Cuórum
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 885a154beca10592
  example-scenario: 2c4be2012a2bcba4
generated:
  introduction: ad2d565c6d1fd41f
  example-scenario: 25f84e26b8b1b250
title_source: 18ed8b6c5ab90343
title_generated: 654fa046f1980103
---

<!-- translation-section: introduction -->

# Quórum

El quórum es el porcentaje mínimo de votantes con derecho a votar que deben participar para que una encuesta se apruebe. Úsalo cuando tu proceso de decisión requiera un nivel mínimo de participación.

Con la [votación ponderada](/en/user_manual/polls/weighted_voting), el quórum utiliza los pesos de los votos. Por ejemplo, Jamie tiene un peso del voto de `2`, Samira de `1` y Alex de `1`. Si solo vota Jamie, ha participado la mitad del peso total de los votos con derecho a participar. Si Samira también vota, la participación alcanza el 75 por ciento y cumple el quórum del 60 por ciento.

Al crear una encuesta, abre **Más configuraciones** e introduce el porcentaje requerido en **Quórum**. Deja el campo en blanco cuando no se requiera quórum.

![La configuración de Quórum con un quórum de participación del 60 por ciento](./quorum-section.png)

También puedes establecer un quórum en una [plantilla de encuesta](/en/user_manual/polls/poll_templates/) para que las encuestas creadas a partir de esa plantilla lo usen de forma predeterminada.

Si una encuesta se cierra sin alcanzar el quórum, Loomio muestra que no se ha cumplido el quórum. La encuesta no se amplía ni se cancela automáticamente; un admin del hilo puede reabrir la encuesta (si está permitido) o compartir una conclusión que explique qué ocurre a continuación.

<!-- translation-section: example-scenario -->

## Ejemplo de situación

La cooperativa Oatmilk está debatiendo una prueba de seis semanas con botellas retornables y necesita aprobar el presupuesto de la prueba.

Jamie selecciona **Iniciar una votación**, elige una plantilla de propuesta y completa el título, los detalles, las opciones, la duración y la configuración de votantes.

![El título, los detalles, las opciones, la duración y la configuración de votantes de la propuesta](proposal-options.png)

Jamie limita la votación a las cinco personas responsables del presupuesto de la prueba. Como la cooperativa requiere un 60 por ciento de participación para las decisiones importantes, Jamie introduce **60** en **Quórum** e inicia la propuesta.

Antes de que alguien vote, el panel de resultados muestra que no se ha alcanzado el quórum.

![Ningún voto emitido y el quórum del 60 por ciento aún sin alcanzar](pie-chart-0.png)

Jamie vota De acuerdo y Samira vota En desacuerdo. El gráfico se actualiza, pero la participación de dos de los cinco votantes con derecho a votar representa solo un 40 por ciento, por lo que aún no se alcanza el quórum.

![Dos de los cinco votos emitidos y el quórum aún sin alcanzar](pie-chart-40.png)

A continuación, Alex vota De acuerdo. Han participado tres de los cinco votantes con derecho a votar, lo que alcanza el quórum del 60 por ciento. El requisito ahora muestra una marca de verificación verde. Jamie puede cerrar la encuesta antes de tiempo o esperar a los votantes restantes.

![Tres de los cinco votos emitidos y el quórum del 60 por ciento alcanzado](pie-chart-60.png)
