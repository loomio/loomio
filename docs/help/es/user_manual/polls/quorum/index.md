---
title: Cuórum
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 9eabda93ec428d90
  example-scenario: 8851316d1f8e92cc
title_source: 18ed8b6c5ab90343
title_generated: 654fa046f1980103
---

<!-- translation-section: introduction -->

# Quórum

El quórum es el porcentaje mínimo de votantes con derecho a votar que deben participar para que una encuesta sea válida. Úsalo cuando tu proceso de gobernanza requiera un nivel determinado de participación.

Al crear una encuesta, abre **Más configuraciones** e introduce el porcentaje requerido en **Cuórum de participación**. Deja el campo en blanco cuando no se requiera quórum.

![La configuración de quórum con un quórum de participación del 60 por ciento](./quorum-section.png)

También puedes establecer un quórum en una [plantilla de encuesta](/en/user_manual/polls/poll_templates/) para que las encuestas creadas a partir de esa plantilla lo usen de forma predeterminada.

<!-- translation-section: example-scenario -->

## Ejemplo de situación

La cooperativa Oatmilk está debatiendo una prueba de seis semanas con botellas retornables. La discusión ha llegado al punto en que la cooperativa necesita aprobar el presupuesto de la prueba.

Jamie selecciona **Iniciar una votación**, elige la plantilla de propuesta **Consentimiento** y completa el título, los detalles, las opciones, la duración y la configuración de votantes.

![El título, los detalles, las opciones, la duración y la configuración de votantes de la propuesta](proposal-options.png)

Jamie limita la votación a las cinco personas responsables del presupuesto de la prueba.

La cooperativa requiere un 60 por ciento de participación para las decisiones importantes, así que Jamie introduce **60** en el campo de quórum de participación e inicia la propuesta.

Antes de que alguien vote, el panel de resultados muestra que no se ha alcanzado el quórum.

![Ningún voto emitido y el quórum del 60 por ciento aún sin alcanzar](pie-chart-0.png)

Jamie vota De acuerdo y Samira vota En desacuerdo. El gráfico se actualiza, pero la participación de dos de los cinco votantes con derecho a votar representa solo un 40 por ciento, por lo que aún no se alcanza el quórum.

![Dos de los cinco votos emitidos y el quórum aún sin alcanzar](pie-chart-40.png)

A continuación, Alex vota De acuerdo. Han participado tres de los cinco votantes con derecho a votar, lo que alcanza el quórum del 60 por ciento. El requisito ahora muestra una marca de verificación verde. Jamie puede cerrar la encuesta antes de tiempo o esperar a los votantes restantes.

![Tres de los cinco votos emitidos y el quórum del 60 por ciento alcanzado](pie-chart-60.png)
