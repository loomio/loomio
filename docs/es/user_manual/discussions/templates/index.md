---
title: Plantillas de discusión
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 9b2b30212a057b4b
  how-templates-are-used: 7d5681170fe9911e
  choose-who-is-notified-by-default: e9fe4c939442f514
  template-settings: 2e71090b3d149213
  example-bottle-trial-review: 20009020c0b68fdf
  create-a-template: 223eee427ebb52bb
  manage-the-template-list: 9a4957687be2b34d
  share-templates-between-groups: 2bff30bad2a0eb4a
  let-members-create-templates: 0cfd990ff48a1a09
  templates-for-non-members: ebaf610bf85e81a9
  related: 6f4cc2ccf8e709d3
generated:
  introduction: a3b7e43580c06c4b
  how-templates-are-used: f10451d9e9732db8
  choose-who-is-notified-by-default: 914a15ff14c3351c
  template-settings: 8e12ee2bdaf0589b
  example-bottle-trial-review: 2bcaa4a905e96e16
  create-a-template: ad598d12bdf95deb
  manage-the-template-list: 554cbe4f4eec9968
  share-templates-between-groups: f9237707a9119bda
  let-members-create-templates: 9bd189a9f21f1e8b
  templates-for-non-members: e6d4f754f53e8872
  related: 3d0a6f649a610afc
title_source: 5ac608aa42806d13
title_generated: 6e52ea675fe98e39
---

<!-- translation-section: introduction -->

# Plantillas de discusión

Las plantillas de discusión ayudan a tu grupo a iniciar las discusiones de la misma manera cada vez. Una plantilla puede incluir un título, contexto, etiquetas e instrucciones para la persona que inicia la discusión. También establece valores predeterminados, como si se debe notificar a todo el grupo y qué encuestas sugerir.

Cada nueva discusión en un grupo parte de una plantilla. Cuando alguien selecciona **Iniciar discusión**, Loomio muestra las plantillas del grupo. Incluso **Plantilla en blanco** es una plantilla, por lo que tu grupo también puede cambiar sus valores predeterminados.

Las plantillas son útiles para procesos que tu grupo repite, como revisiones de proyectos, procesos de asesoramiento, preparación de reuniones, decisiones de financiación o aprobación de documentos. La persona que inicia la discusión puede editarlo todo antes de iniciarla.

<!-- translation-section: how-templates-are-used -->

## Cómo se usan las plantillas

1. Un miembro selecciona **Iniciar discusión** en la página del grupo.
2. Loomio muestra las plantillas visibles del grupo. Cada una muestra su título y subtítulo.
3. El miembro selecciona una plantilla. Loomio abre el formulario de nueva discusión con los datos de la plantilla.
4. La ayuda de la plantilla aparece en la parte superior del formulario como orientación.
5. El miembro edita el título, el contexto, las etiquetas y la lista de invitaciones, y luego selecciona **Iniciar discusión**.

![](list.png)

Cambiar una plantilla solo afecta a las discusiones iniciadas después del cambio. Las discusiones ya iniciadas a partir de ella conservan su contenido y configuración.

<!-- translation-section: choose-who-is-notified-by-default -->

## Elige quién recibe notificaciones de forma predeterminada

La configuración **Invitar** controla a quién invita de forma predeterminada el formulario de nueva discusión. Tiene dos opciones:

- **Todos en el grupo**: el grupo aparece en el campo **Invitar** del formulario de discusión y todos los miembros reciben una notificación cuando se inicia la discusión.
- **Ninguno**: el campo **Invitar** empieza vacío. Nadie recibe una notificación a menos que el autor añada personas.

Las plantillas incluidas en Loomio, entre ellas **Plantilla en blanco**, usan **Todos en el grupo**. Si tu grupo no quiere que cada nueva discusión notifique a todos los miembros, edita las plantillas que usa tu grupo y establece **Invitar** en **Ninguno**.

![](use.png)

El autor siempre puede cambiar la lista de invitaciones antes de iniciar la discusión. Puede quitar al grupo para no notificar a nadie o añadir a personas concretas. Esta configuración solo afecta a las notificaciones. Los miembros del grupo pueden seguir encontrando y leyendo la discusión en el grupo, sea cual sea la opción que elijas.

El grupo solo se añade a la lista de invitaciones cuando el autor tiene permiso para notificar a todo el grupo. Los admins siempre pueden hacerlo. Los miembros pueden hacerlo cuando **Los miembros pueden notificar a cualquiera en el grupo** está activado en los permisos del grupo.

<!-- translation-section: template-settings -->

## Configuración de la plantilla

Los admins del grupo pueden editar una plantilla desde el menú de acciones que aparece junto a ella en la lista de plantillas. El formulario tiene estas opciones de configuración:

![](form.png)

- **Título de la plantilla**: el nombre breve que aparece en la lista de plantillas.
- **Subtítulo de plantilla**: una línea que explica cuándo usar la plantilla.
- **Ayuda con la plantilla**: instrucciones que aparecen en la parte superior del formulario de nueva discusión. Úsala para explicar el proceso y enlazar a recursos. No forma parte de la discusión.
- **Grupo**: si la plantilla inicia una discusión en el grupo o una discusión directa. Una discusión directa solo es visible para las personas invitadas a ella.
- **Título predeterminado**: un título que se rellena en cada nueva discusión. El autor puede editarlo.
- **Título de ejemplo**: un ejemplo que aparece en el campo del título cuando está vacío. Úsalo cuando un título predeterminado no encaje en todas las discusiones.
- **Etiquetas**: etiquetas que se aplican a cada nueva discusión. El autor puede quitarlas.
- **Contexto**: el texto inicial de la discusión. Usa encabezados, preguntas o enlaces para orientar lo que escriben las personas.
- **Invitar**: si se invita a todos en el grupo de forma predeterminada. Consulta [Elige quién recibe notificaciones de forma predeterminada](#choose-who-is-notified-by-default).
- **Plantillas de encuestas**: encuestas sugeridas para este proceso. Se muestran en el formulario de nueva discusión. También aparecen primero cuando alguien inicia una encuesta en la discusión. No se inician automáticamente.
- **Permitir sondeos simultáneos**: si puede haber más de una encuesta abierta en la discusión al mismo tiempo.
- **Límite de longitud de los comentarios**: una longitud máxima opcional para los comentarios.

Usa un título predeterminado solo cuando vaya a seguir siendo adecuado. En caso contrario, escribe un título de ejemplo que anime al autor a nombrar la revisión, el período, el documento o la decisión concreta.

<!-- translation-section: example-bottle-trial-review -->

## Ejemplo: revisión de la prueba de botellas

Oatmilk Cooperative revisa su prueba de botellas retornables después de cada ciclo. Su plantilla se titula "Revisión de la prueba de botellas" y tiene un título predeterminado. Añade la etiqueta "Prueba de botellas". Su contexto pide a los miembros que lean el informe semanal y tengan en cuenta las tasas de devolución, los registros de lavado, los comentarios de las cafeterías y los costes de transporte. Recomienda una toma de pulso seguida de Consentimiento.

Esto funciona como plantilla porque el propósito y la información que se analiza se mantienen en cada ciclo. Solo cambian las observaciones y las decisiones.

<!-- translation-section: create-a-template -->

## Crea una plantilla

Los admins del grupo pueden seleccionar **Nueva plantilla** en la lista de plantillas. Elige un ejemplo de la galería de Loomio o empieza con una plantilla en blanco, luego adáptala y guárdala.

Puedes buscar o filtrar la galería. Un ejemplo no se añade a tu grupo hasta que lo guardas.

<!-- translation-section: manage-the-template-list -->

## Gestiona la lista de plantillas

Cuando se crea un grupo, Loomio añade un conjunto de plantillas adecuadas al tipo de grupo. Al principio, solo son visibles **Plantilla en blanco** y **Discusión práctica**. Las demás están ocultas y los admins pueden mostrarlas.

Los admins del grupo pueden usar el menú de acciones junto a una plantilla para:

- editar su contenido y configuración;
- ocultarla en la lista de plantillas;
- volver a mostrarla desde **Plantillas ocultas**;
- cambiar el orden de las plantillas visibles;
- exportarla como archivo JSON; o
- eliminarla.

Ocultar una plantilla la conserva para usarla más adelante. Eliminar una plantilla no elimina las discusiones iniciadas a partir de ella.

<!-- translation-section: share-templates-between-groups -->

## Comparte plantillas entre grupos

Selecciona **Exportar json** en el menú de acciones de una plantilla para descargarla como archivo. Para usarla en otro grupo, selecciona **Nueva plantilla** y luego **Importar json**. El formulario se abre con el contenido importado para que puedas revisarlo antes de guardarlo.

Los enlaces a plantillas de encuestas personalizadas no se incluyen en el archivo. Exporta e importa esas plantillas de encuestas por separado.

<!-- translation-section: let-members-create-templates -->

## Permite que los miembros creen plantillas

De forma predeterminada, solo los admins del grupo pueden crear y editar plantillas. Un admin puede activar **Los miembros pueden crear plantillas** en **Configuración del grupo** → **Permisos**.

Cuando esta opción está activada, los miembros pueden crear plantillas de discusión y de encuesta y editar las plantillas que hayan creado. Los admins pueden editar todas las plantillas del grupo. La plantilla de un miembro aparece en la lista de plantillas del grupo en cuanto se guarda, así que acuerda con tu grupo cómo nombrar y revisar las plantillas antes de activar este permiso.

<!-- translation-section: templates-for-non-members -->

## Plantillas para personas que no son miembros

Si **Los no miembros pueden iniciar debates** está activado, las personas ajenas al grupo eligen en la misma lista de plantillas. Su formulario de discusión nunca invita al grupo de forma predeterminada. Consulta [Recoge aportaciones privadas](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Contenido relacionado

- [Plantillas de encuestas](/en/user_manual/polls/poll_templates)
