---
title: Privacidad
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/settings/privacy.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 72b58ba22851f914
  open: 1727e8f20fe92fb2
  follow-an-open-group: e4a1b3ce35a974d0
  closed: 53c3d50151a2115b
  secret: fcb55fcb64d44881
  how-people-join: f61d4f7e0f88106a
  group-directory: 4ef3023e3cf4efdf
  visible-to-parent-group: a9a3ece6458f080e
generated:
  introduction: b09fe9b44b10d12b
  open: 73ffbe645be01ea4
  follow-an-open-group: 99f35f1d55a7e211
  closed: 458b29451b0ce14b
  secret: 75dc3082d4aeef4b
  how-people-join: 83980fe1c0d1c85f
  group-directory: 48d925ceb92be2d2
  visible-to-parent-group: 211c3686d590908c
title_source: 54a57c3147c49f33
title_generated: 52233e2c4d6b2e9a
needs_review:
  secret: check the interface label "**Secreto**" for "**Secret**"
  how-people-join: check the interface label "**Secreto**" for "**Secret**"
---

<!-- translation-section: introduction -->

# Privacidad del grupo

La privacidad controla quién puede encontrar un grupo y quién puede leer su contenido. Abre **Editar la configuración del grupo** desde la página del grupo y selecciona **Privacidad**.

![Configuración de privacidad del grupo](group_privacy_settings.png#width-90)

Cambiar la privacidad puede mostrar u ocultar el contenido existente del grupo, no solo el que se cree después. Elige la configuración más restrictiva que permita cumplir el propósito del grupo.

<!-- translation-section: open -->

## Abierto

Los grupos abiertos son espacios públicos. Cualquier persona puede encontrar el grupo y leer sus discusiones, encuestas y archivos. La lista de miembros sigue siendo visible solo para los miembros.

Los grupos abiertos pueden permitir que las personas se unan de inmediato, exigir aprobación o admitir miembros solo por invitación.

<!-- translation-section: follow-an-open-group -->

### Seguir un grupo abierto

Las personas pueden mantenerse al día con un grupo abierto sin unirse. Seguir un grupo añade la actividad no leída del grupo a su correo de resumen para que puedan revisarla cuando les convenga. Seguir el grupo no convierte a las personas en miembros, no les otorga los derechos de voto de los miembros ni hace que reciban notificaciones inmediatas.

Activa **Sigue las actualizaciones** en la página del grupo para incluir las discusiones, los comentarios, las encuestas y otras actividades de los hilos que no hayas leído en tu correo de resumen. Desactiva esta opción para dejar de incluir el grupo.

![Seguir las actualizaciones de un grupo abierto](group_follow_updates.png)

<!-- translation-section: closed -->

## Cerrado

Cualquier persona puede encontrar un grupo cerrado y leer su nombre y descripción. Las discusiones, las encuestas, los archivos y la lista de miembros son privados y solo están disponibles para los miembros y los invitados.

Los grupos principales cerrados pueden permitir que las personas soliciten unirse o admitir miembros solo por invitación. No pueden permitir que las personas se unan de inmediato sin aprobación.

Los subgrupos cerrados también pueden permitir que cualquier persona se una sin aprobación. Para que solo los miembros del grupo principal puedan encontrar el subgrupo y unirse de inmediato, selecciona **Visible para el grupo principal**.

Un subgrupo cerrado puede permitir que los miembros del grupo principal lean sus discusiones sin unirse al subgrupo.

<!-- translation-section: visible-to-parent-group -->

## Visible para el grupo principal

Esta configuración permite que los miembros del grupo principal encuentren el subgrupo, mientras que sus hilos siguen siendo privados y solo están disponibles para los miembros del subgrupo y los invitados. Las personas que no pertenecen a ninguno de los dos grupos no pueden encontrarlo, incluso cuando el grupo principal es público.

Selecciona **Visible para el grupo principal** y luego **Los miembros de [grupo principal] pueden unirse sin aprobación** para que los miembros del grupo principal puedan unirse por su cuenta. Al unirse, pasan a ser miembros del subgrupo con los permisos habituales, incluido el acceso a sus hilos privados. También puedes exigir aprobación o permitir unirse solo por invitación.

El subgrupo conserva esta visibilidad cuando el grupo principal pasa a ser público. Si el grupo principal pasa a ser privado, sus subgrupos públicos pasan a ser **Visible para el grupo principal** y sus hilos pasan a ser privados. Los subgrupos secretos siguen siendo secretos. Los subgrupos existentes que antes aparecían como cerrados dentro de un grupo principal privado ahora muestran **Visible para el grupo principal**, sin cambios en el acceso existente.

Para permitir que los miembros del grupo principal lean los hilos privados antes de unirse, activa **Los miembros de [grupo principal] pueden ver los hilos privados** en **Permisos**. Esto permite leer los hilos, sin otorgar la condición de miembro del subgrupo ni derechos de voto.

<!-- translation-section: secret -->

## Secreto

Los grupos secretos y su contenido son visibles solo para las personas que hayan sido invitadas o añadidas. Solo es posible unirse por invitación. Los grupos secretos no aparecen en el directorio público de grupos.

Un grupo principal secreto solo admite subgrupos **Visible para el grupo principal** y **Secreto **. Sus subgrupos no pueden ser abiertos ni cerrados.

<!-- translation-section: how-people-join -->

## Cómo unirse

La privacidad determina qué opciones están disponibles para unirse:

| Privacidad del grupo | Opciones disponibles para unirse |
| --- | --- |
| **Abierto** | Cualquier persona puede unirse, solicitar aprobación o unirse solo por invitación |
| **Grupo principal cerrado** | Solicitar aprobación o unirse solo por invitación |
| **Subgrupo cerrado** | Cualquier persona puede unirse, solicitar aprobación o unirse solo por invitación |
| **Visible para el grupo principal** | Los miembros del grupo principal pueden unirse, solicitar aprobación o unirse solo por invitación |
| **Secreto ** | Solo por invitación |

La posibilidad de unirse de inmediato depende de la visibilidad del grupo. En un subgrupo público, cualquier persona puede unirse. En un subgrupo **Visible para el grupo principal**, los miembros del grupo principal pueden unirse. Los miembros pueden salir y volver a unirse mientras sigan cumpliendo los requisitos. Cambiar la forma de unirse no cambia quién puede leer los hilos privados antes de unirse.

Cuando se requiere aprobación, las personas seleccionan **Unirse al grupo**, responden a la pregunta del grupo para unirse y envían una solicitud. Consulta [Invitar a personas](/en/user_manual/groups/inviting_people#request-to-join-group) para saber cómo configurar la pregunta, revisar las solicitudes e invitar a personas directamente.

<!-- translation-section: group-directory -->

## Directorio de grupos

Los grupos principales abiertos y cerrados pueden aparecer en el directorio público de grupos para que las personas puedan encontrarlos. Aparecer en el directorio no cambia quién puede leer el contenido del grupo o convertirse en miembro. Los subgrupos y los grupos secretos no pueden aparecer en el directorio.
