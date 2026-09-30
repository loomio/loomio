---
title: Plantillas de sondeo
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: f11182d62d99dbcc
  voting-methods-and-templates: 24be471686aa2dfd
  use-a-template: 8b19cdf141c41c9b
  who-can-manage-templates: 60218ef791438e19
  create-a-poll-template: c20dd8c57c3deab0
  template-title-subtitle-and-help: 3ad53a8b118aabd3
  voting-method: 761137852812fea8
  example-title-details-and-tags: 9dbbd0510d2d6cc1
  response-options: 727afbf0dcea6069
  duration-and-settings: dc1fb9123eb808df
  save-and-test-the-template: 8c48386c69ea309a
  manage-the-template-list: 0c124d7958c3f80a
generated:
  introduction: 5228eab7d773bdf5
  voting-methods-and-templates: 477459bcbd13123a
  use-a-template: 7ce983ecaa79708f
  who-can-manage-templates: 0e07c784dc71994c
  create-a-poll-template: 07e9fc7e524ec1d8
  template-title-subtitle-and-help: abdc1a6d1721784d
  voting-method: aabf9ee3e037aad3
  example-title-details-and-tags: e6e5c0f85d0a5502
  response-options: 7c4e9318c5dea508
  duration-and-settings: c48aae1d7103d104
  save-and-test-the-template: 5408eaeda10025e6
  manage-the-template-list: 60edd845a45cf6d9
title_source: 114cca246e357304
title_generated: ab9dd5c48dbfb316
---

<!-- translation-section: introduction -->

# Plantillas de sondeo

Las plantillas de sondeo son puntos de partida reutilizables que aparecen al seleccionar **Iniciar una votación** o **Nuevo sondeo**. Cada plantilla combina un método de votación con instrucciones, opciones de respuesta y ajustes predefinidos.

Usa esta página para configurar qué plantillas están disponibles para un grupo o crear una para tu propio proceso. Para elegir una plantilla para una votación concreta, consulta [Propuestas](../proposals/) o [Sondeos](../proposal_types/). Para facilitar un proceso de decisión completo, consulta [Tomar decisiones](/en/guides/making_decisions/).

<!-- translation-section: voting-methods-and-templates -->

## Métodos de votación y plantillas

El método de votación determina cómo responden los participantes y cómo calcula Loomio el resultado. Algunos ejemplos son Propuesta, Elegir, Puntaje, Asignar, Rango, Coordinar horario y STV.

Una plantilla de sondeo utiliza uno de esos métodos y añade valores predeterminados reutilizables. Por ejemplo, Comprobación de opiniones, Asesoramiento, Consentimiento y Consenso son plantillas distintas basadas en el método de votación Propuesta. Sus instrucciones y opciones de respuesta son diferentes, aunque Loomio procesa los votos de la misma manera.

<!-- translation-section: use-a-template -->

## Usar una plantilla

Al iniciar una votación, selecciona la pestaña **Propuesta** o **Encuesta** y elige una de las plantillas disponibles para el grupo.

![](proposal_templates_list.png)

La plantilla incluye una introducción, contenido de ejemplo, opciones y ajustes. Revísalos y edítalos para la decisión concreta antes de iniciar la votación. Los cambios que hagas en la nueva votación no modifican la plantilla reutilizable.

<!-- translation-section: who-can-manage-templates -->

## Quién puede gestionar las plantillas

Los administradores de un grupo pueden crear y gestionar todas sus plantillas de sondeo. Pueden activar **Los miembros pueden crear plantillas** en **Configuración del grupo** → **Permisos**. Si esta opción está activada, los miembros pueden crear plantillas y gestionar las que hayan creado.

<!-- translation-section: create-a-poll-template -->

## Crear una plantilla de sondeo

Abre la lista de plantillas y selecciona **Nueva plantilla**. Empieza con un ejemplo o una plantilla en blanco y elige el grupo que la utilizará.

![](proposal_template_setting.png)

El formulario de la plantilla define las instrucciones y los valores predeterminados que reciben las personas al iniciar una votación.

![](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### Título, subtítulo y ayuda de la plantilla

- **Título de la plantilla** es el nombre breve que aparece en la lista de plantillas.
- **Subtítulo de plantilla** explica en una frase cuándo usarla.
- **Ayuda con la plantilla** aparece en el panel de información cuando alguien utiliza la plantilla. Explica su propósito, las reglas que deben conocer los participantes y los enlaces a políticas o guías pertinentes.

![](template_WAAP_intro.png)

Usa nombres claros y específicos que permitan distinguir la plantilla de las demás del grupo.

<!-- translation-section: voting-method -->

### Método de votación

Elige qué necesitan expresar los participantes y cómo debe calcularse el resultado.

![](poll_type_voting_method.png)

- **Propuesta**: responder a una afirmación con posturas definidas;
- **Elegir**: seleccionar una o varias opciones;
- **Puntaje**: evaluar cada opción en una escala;
- **Asignar**: distribuir una cantidad limitada de puntos;
- **Rango**: ordenar las opciones según las preferencias;
- **Coordinar horario**: indicar la disponibilidad; y
- **STV**: ordenar candidatos por preferencia en una elección proporcional con varios puestos.

Al cambiar el método de votación, cambian los campos y el cálculo del resultado disponibles para la plantilla.

<!-- translation-section: example-title-details-and-tags -->

### Título, detalles y etiquetas de ejemplo

Incluye contenido de ejemplo que ayude a plantear la votación. Estos valores se copian en una nueva propuesta o encuesta y pueden editarse antes de iniciarla.

![](template_WAAP_details.png)

Usa indicaciones en lugar de contenido fijo cuando cada votación necesite un título o unos detalles diferentes. Añade etiquetas de categoría predeterminadas solo si corresponden en todos los usos de la plantilla.

<!-- translation-section: response-options -->

### Opciones de respuesta

Métodos como Propuesta y Elegir permiten configurar las opciones de respuesta. Selecciona el icono del lápiz junto a una opción para editar:

- **Nombre de la opción**: la etiqueta breve de la respuesta;
- **Icono**: su símbolo visual;
- **Significado**: lo que comunica seleccionar la opción; y
- **Mensaje de motivo**: la pregunta que aparece cuando alguien explica su respuesta.

![](poll_type_edit_option.png)

Define las opciones de forma que los participantes puedan distinguirlas sin tener que adivinar. Sus significados deben corresponder a las reglas de decisión que utiliza tu grupo.

<!-- translation-section: duration-and-settings -->

### Duración y ajustes

Establece una duración predeterminada adecuada para la mayoría de los usos de la plantilla. Quien cree una votación puede cambiar su hora de cierre.

![](poll_type_duration.png)

Otros valores predeterminados pueden controlar la visibilidad de los resultados, el voto anónimo, la obligación de explicar el voto, los recordatorios, el cuórum y las funciones propias de cada método. Consulta [Ajustes de propuestas y encuestas](../settings/) para conocer sus efectos.

<!-- translation-section: save-and-test-the-template -->

### Guardar y probar la plantilla

Después de guardar la plantilla, inicia un borrador de votación a partir de ella. Comprueba que la introducción, las indicaciones, las opciones y los valores predeterminados resulten claros para alguien que no la haya creado. El borrador también te permite confirmar que el método de votación elegido produce el resultado que espera el grupo.

<!-- translation-section: manage-the-template-list -->

## Gestionar la lista de plantillas

Usa el menú de acciones junto a una plantilla para:

- **Editar** su contenido reutilizable y sus valores predeterminados;
- **Mover** la plantilla a otra posición de la lista;
- **Esconder** la plantilla a quienes inician votaciones; o
- **Eliminar** una plantilla personalizada que ya no se necesite.

![](template_manage.png)

Selecciona **Mostrar plantillas ocultas** para revisar o restaurar las plantillas ocultas. Las plantillas predeterminadas pueden ocultarse o adaptarse para el grupo, pero no eliminarse.

![](template_manage_settings.png)

Los cambios en una plantilla no modifican las propuestas ni las encuestas que ya se hayan iniciado a partir de ella.
