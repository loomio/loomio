---
title: Cuórum
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: a43657732aa060e9
  example-scenario: 866935d980276bf1
title_source: 18ed8b6c5ab90343
title_generated: 654fa046f1980103
---

<!-- translation-section: introduction -->

# Cuórum

El cuórum es el porcentaje mínimo de personas con derecho a voto que deben participar para que una votación sea válida. Úsalo cuando el proceso de toma de decisiones de tu grupo requiera un nivel determinado de participación.

Al crear una votación, abre **Más configuraciones** e introduce el porcentaje requerido en **Cuórum de participación**. Deja el campo en blanco si no se requiere un cuórum.

![La configuración del cuórum con un cuórum de participación del 60 por ciento](./quorum-section.png)

También puedes establecer un cuórum en una [plantilla de votación](/en/user_manual/polls/poll_templates/) para que las votaciones creadas con esa plantilla lo incluyan de forma predeterminada.

<!-- translation-section: example-scenario -->

## Ejemplo

La Cooperativa Oatmilk está debatiendo una prueba de seis semanas con botellas retornables. La discusión ha llegado al punto en que la cooperativa debe aprobar el presupuesto de la prueba.

Jamie selecciona **Iniciar una votación**, elige la plantilla de propuesta **Consentimiento** y completa el título, los detalles, las opciones, la duración y la configuración de las personas con derecho a voto.

![El título, los detalles, las opciones, la duración y la configuración de las personas con derecho a voto de la propuesta](proposal-options.png)

Jamie limita la votación a las cinco personas responsables del presupuesto de la prueba.

La cooperativa exige una participación del 60 por ciento para las decisiones importantes. Por eso, Jamie introduce **60** en el campo de cuórum de participación e inicia la propuesta.

Antes de que nadie vote, el panel de resultados muestra que aún no se ha alcanzado el cuórum.

![Nadie ha votado y aún no se ha alcanzado el cuórum del 60 por ciento](pie-chart-0.png)

Jamie está de acuerdo y Samira está en desacuerdo. El gráfico se actualiza, pero solo han participado dos de las cinco personas con derecho a voto: un 40 por ciento. Por tanto, aún no se ha alcanzado el cuórum.

![Han votado dos de cinco personas y aún no se ha alcanzado el cuórum](pie-chart-40.png)

Después, Alex está de acuerdo. Han participado tres de las cinco personas con derecho a voto y se alcanza el cuórum del 60 por ciento. El requisito muestra ahora una marca de verificación verde. Jamie puede cerrar la votación antes de tiempo o esperar a las demás personas.

![Han votado tres de cinco personas y se ha alcanzado el cuórum del 60 por ciento](pie-chart-60.png)
