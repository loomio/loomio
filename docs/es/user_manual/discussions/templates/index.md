---
title: Plantillas de discusión
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
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
  introduction: 96ddd8cf044118a9
  how-templates-are-used: a912be604ce0a4ba
  choose-who-is-notified-by-default: 2a6aa476053c9d11
  template-settings: d197c57295823f48
  example-bottle-trial-review: d4805bbc54f1862c
  create-a-template: 84e20594b0c56c81
  manage-the-template-list: 9f94a8b95880281d
  share-templates-between-groups: 4d0b6d18a302408d
  let-members-create-templates: da814de3e3b99735
  templates-for-non-members: 199b7fd0ec77361d
  related: a387020cff4da1c2
title_source: 5ac608aa42806d13
title_generated: 6e52ea675fe98e39
---

<!-- translation-section: introduction -->

# Plantillas de discusión

Las plantillas de discusión ayudan a tu grupo a iniciar las discusiones de la misma manera cada vez. Una plantilla puede incluir un título, contexto, etiquetas e instrucciones para quien inicia la discusión. También establece valores predeterminados, como si se notificará a todo el grupo y qué sondeos se sugerirán.

Cada nueva discusión de un grupo parte de una plantilla. Cuando alguien selecciona **Iniciar discusión**, Loomio muestra las plantillas del grupo. Incluso **Plantilla en blanco** es una plantilla, así que tu grupo también puede cambiar sus valores predeterminados.

Las plantillas son útiles para procesos que tu grupo repite, como revisiones de proyectos, consultas, preparación de reuniones, decisiones de financiación o aprobación de documentos. Quien inicia la discusión puede editarlo todo antes de iniciarla.

<!-- translation-section: how-templates-are-used -->

## Cómo se usan las plantillas

1. Un miembro selecciona **Iniciar discusión** en la página del grupo.
2. Loomio muestra las plantillas visibles del grupo. Cada una muestra su título y subtítulo.
3. El miembro selecciona una plantilla. Loomio abre el formulario de nueva discusión con el contenido de la plantilla.
4. La ayuda de la plantilla aparece en la parte superior del formulario.
5. El miembro edita el título, el contexto, las etiquetas y la lista de invitados, y luego selecciona **Iniciar discusión**.

![](list.png)

Los cambios en una plantilla solo afectan a las discusiones iniciadas después del cambio. Las discusiones ya iniciadas con ella conservan su contenido y configuración.

<!-- translation-section: choose-who-is-notified-by-default -->

## Elige a quién notificar de forma predeterminada

La opción **Invitar** controla a quién invita de forma predeterminada el formulario de nueva discusión. Tiene dos opciones:

- **Todos en el grupo**: el grupo aparece en el campo **Invitar** del formulario de discusión y cada miembro recibe una notificación cuando comienza la discusión.
- **Ninguno**: el campo **Invitar** aparece vacío. Nadie recibe una notificación a menos que quien inicia la discusión añada personas.

Las plantillas incluidas en Loomio, entre ellas **Plantilla en blanco**, usan **Todos en el grupo**. Si tu grupo no quiere que cada nueva discusión notifique a todos los miembros, edita las plantillas que utiliza y cambia **Invitar** a **Ninguno**.

![](use.png)

Quien inicia la discusión siempre puede cambiar la lista de invitados antes de iniciarla. Puede quitar al grupo para no notificar a nadie o añadir personas concretas. Esta opción solo afecta a las notificaciones. Los miembros del grupo pueden encontrar y leer la discusión en el grupo con cualquiera de las dos opciones.

El grupo solo se añade a la lista de invitados cuando quien inicia la discusión tiene permiso para notificar a todo el grupo. Los administradores siempre pueden hacerlo. Los miembros pueden hacerlo si **Los miembros pueden notificar a cualquiera en el grupo** está habilitado en los permisos del grupo.

<!-- translation-section: template-settings -->

## Configuración de la plantilla

Los administradores del grupo pueden editar una plantilla desde el menú de acciones situado junto a ella en la lista de plantillas. El formulario incluye estas opciones:

![](form.png)

- **Título de la plantilla**: el nombre corto que aparece en la lista de plantillas.
- **Subtítulo de plantilla**: una línea que explica cuándo usar la plantilla.
- **Ayuda con la plantilla**: instrucciones que aparecen en la parte superior del formulario de nueva discusión. Úsalas para explicar el proceso y enlazar recursos. No forman parte de la discusión.
- **Grupo**: indica si la plantilla inicia una discusión en el grupo o una discusión directa. Una discusión directa solo es visible para las personas invitadas.
- **Título predeterminado**: un título que se rellena en cada nueva discusión. Quien la inicia puede editarlo.
- **Título de ejemplo**: un ejemplo que aparece en un campo de título vacío. Úsalo cuando un título predeterminado no sirva para todas las discusiones.
- **Etiquetas**: etiquetas que se aplican a cada nueva discusión. Quien la inicia puede quitarlas.
- **Contexto**: el texto inicial de la discusión. Usa encabezados, preguntas o enlaces para orientar lo que escriben las personas.
- **Invitar**: indica si se invita a todos los miembros del grupo de forma predeterminada. Consulta [Elige a quién notificar de forma predeterminada](#choose-who-is-notified-by-default).
- **Plantillas de encuestas**: sondeos sugeridos para este proceso. Aparecen en el formulario de nueva discusión y también al principio de la lista cuando alguien inicia un sondeo en la discusión. No se inician automáticamente.
- **Permitir sondeos simultáneos**: indica si puede haber más de un sondeo abierto a la vez en la discusión.
- **Límite de longitud de los comentarios**: una longitud máxima opcional para los comentarios.

Usa un título predeterminado solo si seguirá siendo adecuado. De lo contrario, escribe un título de ejemplo que anime a quien inicia la discusión a indicar la revisión, el periodo, el documento o la decisión concreta.

<!-- translation-section: example-bottle-trial-review -->

## Ejemplo: revisión de la prueba de botellas

La Cooperativa Leche de Avena revisa su prueba de botellas retornables después de cada ciclo. Su plantilla se llama «Revisión de la prueba de botellas» y tiene un título predeterminado. Añade la etiqueta «Prueba de botellas». El contexto pide a los miembros que lean el informe semanal y consideren las tasas de devolución, los registros de lavado, los comentarios de las cafeterías y los costes de transporte. Recomienda primero un sondeo de comprobación y después uno de consentimiento.

La plantilla sirve para este proceso porque el objetivo y la información que se revisa son los mismos en cada ciclo. Solo cambian las observaciones y las decisiones.

<!-- translation-section: create-a-template -->

## Crea una plantilla

Los administradores del grupo pueden seleccionar **Nueva plantilla** en la lista de plantillas. Elige un ejemplo de la galería de Loomio o empieza con una plantilla en blanco. Después, adáptala y guárdala.

Puedes buscar o filtrar los ejemplos de la galería. Un ejemplo no se añade a tu grupo hasta que lo guardas.

<!-- translation-section: manage-the-template-list -->

## Gestiona la lista de plantillas

Al crear un grupo, Loomio añade un conjunto de plantillas adecuadas para ese tipo de grupo. Al principio, solo son visibles **Plantilla en blanco** y **Discusión práctica**. Las demás están ocultas y los administradores pueden mostrarlas.

Los administradores del grupo pueden usar el menú de acciones junto a una plantilla para:

- editar su contenido y configuración;
- ocultarla de la lista de plantillas;
- mostrarla desde **Plantillas ocultas**;
- cambiar el orden de las plantillas visibles;
- exportarla como archivo JSON; o
- eliminarla.

Si ocultas una plantilla, podrás volver a usarla más adelante. Si la eliminas, las discusiones iniciadas con ella permanecen.

<!-- translation-section: share-templates-between-groups -->

## Comparte plantillas entre grupos

Selecciona **Exportar json** en el menú de acciones de una plantilla para descargarla como archivo. Para usarla en otro grupo, selecciona **Nueva plantilla** y luego **Importar json**. El formulario se abre con el contenido importado para que puedas revisarlo antes de guardarlo.

El archivo no incluye enlaces a plantillas de encuestas personalizadas. Exporta e importa esas plantillas de encuestas por separado.

<!-- translation-section: let-members-create-templates -->

## Permite que los miembros creen plantillas

De forma predeterminada, solo los administradores del grupo pueden crear y editar plantillas. Un administrador puede habilitar **Los miembros pueden crear plantillas** en **Configuración del grupo** → **Permisos**.

Cuando esta opción está habilitada, los miembros pueden crear plantillas de discusión y de encuestas, y editar las que hayan creado. Los administradores pueden editar todas las plantillas del grupo. La plantilla de un miembro aparece en la lista del grupo en cuanto se guarda. Por eso, acordad cómo nombrar y revisar las plantillas antes de habilitar este permiso.

<!-- translation-section: templates-for-non-members -->

## Plantillas para personas que no son miembros

Si **Los no miembros pueden iniciar debates** está habilitado, las personas ajenas al grupo eligen entre las mismas plantillas. Su formulario de discusión nunca invita al grupo de forma predeterminada. Consulta [Recopilar aportaciones privadas](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Páginas relacionadas

- [Plantillas de encuestas](/en/user_manual/polls/poll_templates)
