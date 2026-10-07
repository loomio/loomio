---
title: Subgrupos
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/subgroups/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 63e6e23d24e80919
  add-a-subgroup: 0bc0e5f99eb074c3
  subgroup-settings: 737225cc4bebe7e8
  privacy: 5bdd92ce200f197a
  permissions: ee02991523f1ebe4
  find-subgroups: 5e6fc5a5122c1417
  invite-to-a-subgroup: 0af670e1e9b32a5e
  simultaneously-invite-people-to-subgroups-and-parent-group: 1991604900321cd7
  administer-a-subgroup: 58fa95833f79dd01
  delete-a-subgroup: 2c6e76ec78386443
generated:
  introduction: 6ad96a601d7c0b89
  add-a-subgroup: f0b0365a80acc5fe
  subgroup-settings: cfb7850bde221463
  privacy: 77ce64066c8b862e
  permissions: 04ea014727f8d84b
  find-subgroups: 28b3c3488fbdc36d
  invite-to-a-subgroup: cc5655654a8abc56
  simultaneously-invite-people-to-subgroups-and-parent-group: ef5bec1085470e79
  administer-a-subgroup: 90a971a288f1e415
  delete-a-subgroup: 3a8a13578b5d7d1e
title_source: 9f81e728f70cae3e
title_generated: d54ff4541651eb81
---

<!-- translation-section: introduction -->

# Subgrupos

Los subgrupos te ayudan a organizar las comunicaciones y a los miembros para que las personas adecuadas participen en el trabajo conjunto.

Por ejemplo, una organización puede tener los siguientes subgrupos:
- junta directiva
- equipo de trabajo o grupo de trabajo de un proyecto
- un tema (como «estrategia» o «aprendizaje»)

Los subgrupos funcionan igual que los grupos, pero están dentro de tu grupo principal. La mayoría de las funciones y los ajustes disponibles son los mismos que en el grupo principal. Esto también significa que alguien puede ser miembro de tu subgrupo, como tu junta directiva, sin pertenecer a tu grupo principal.

<!-- translation-section: add-a-subgroup -->

## Añadir un subgrupo

>[!Note]
>La posibilidad de añadir nuevos subgrupos forma parte de los [ajustes de permisos](/en/user_manual/groups/settings/permissions) del grupo. De forma predeterminada, solo los admins pueden crear nuevos subgrupos.

Para añadir un subgrupo, visita la página de tu grupo principal y haz clic en **Nuevo subgrupo** en la barra lateral.  

![Botón Nuevo subgrupo en la barra lateral de Oatmilk Cooperative](subgroups-sidebar.png)

Haz clic en el botón **Nuevo subgrupo**, ponle un nombre y selecciona el ajuste de privacidad. Después, haz clic en **Crear subgrupos**.

![Formulario de nuevo subgrupo para el grupo de trabajo de embalaje](subgroups_new.png)

Cuando quieras, [invita a personas](/en/user_manual/groups/inviting_people/) al subgrupo.

Puedes editar los [ajustes del grupo](/en/user_manual/groups/settings/) del subgrupo haciendo clic en el icono de engranaje de la página del subgrupo.

![Opción para editar los ajustes del grupo de trabajo de embalaje](subgroups_edit_group_settings.png)

<!-- translation-section: subgroup-settings -->

## Ajustes del subgrupo

<!-- translation-section: privacy -->

### Privacidad

Elige quién puede encontrar el subgrupo por separado de cómo se unen las personas:

| Privacidad | Quién puede encontrarlo | Quién puede leer sus hilos |
| --- | --- | --- |
| **Abierto** | Cualquier persona | Cualquier persona |
| **Cerrado** | Cualquier persona | Miembros del subgrupo e invitados |
| **Visible para el grupo principal** | Miembros del grupo principal y del subgrupo | Miembros del subgrupo e invitados |
| **Secreto** | Miembros invitados al subgrupo | Miembros del subgrupo e invitados |

Para permitir que los miembros del grupo principal se unan por su cuenta, selecciona **Visible para el grupo principal** y luego **Los miembros de [grupo principal] pueden unirse sin aprobación** en **¿Cómo se unen las personas a este grupo?** al crear el subgrupo, o en **Editar configuración del grupo → Privacidad**. Las personas que no pertenecen al grupo principal necesitan una invitación. Los miembros pueden salir del subgrupo y volver a unirse mientras sigan perteneciendo al grupo principal.

![Configuración de privacidad del subgrupo con visibilidad para el grupo principal y la opción de unirse sin aprobación](subgroups_privacy_settings.png)

Al unirse, una persona pasa a ser un miembro ordinario del subgrupo. Esto no la convierte en admin ni cambia la privacidad de los hilos existentes.

Los subgrupos públicos también pueden permitir que las personas se unan de inmediato; cualquier persona puede unirse cuando esa opción está seleccionada. Cuando el grupo principal es privado, las opciones disponibles para el subgrupo son **Visible para el grupo principal** y **Secreto**.

Un subgrupo **Visible para el grupo principal** sigue siendo privado cuando el grupo principal pasa a ser público. Al hacer privado un grupo principal, el acceso a sus subgrupos públicos se limita a los miembros del grupo principal y sus hilos pasan a ser privados, mientras que los subgrupos secretos se mantienen como están.

[Lee sobre la privacidad de los grupos aquí](/en/user_manual/groups/settings/privacy).

<!-- translation-section: permissions -->

### Permisos

Los subgrupos funcionan de forma independiente del grupo principal. Por ejemplo, si la configuración de privacidad del subgrupo es **Secreto**, solo los miembros invitados pueden encontrarlo, ver quién pertenece a él y ver los hilos.

Los subgrupos con la opción **Cerrado** y los subgrupos **Visible para el grupo principal** pueden permitir que los miembros del grupo principal lean los hilos privados antes de unirse. Activa **Los miembros de [grupo principal] pueden ver los hilos privados** en **Permisos**. Estas personas no obtienen el derecho a votar ni pasan a ser miembros del subgrupo.

![Opción que permite a los miembros del grupo principal ver los hilos privados del subgrupo](subgroups_private_threads_settings.png)

<!-- translation-section: find-subgroups -->

## Encontrar subgrupos

Abre el menú lateral y haz clic en el nombre de tu grupo para ver los subgrupos que contiene.

![Subgrupos de Oatmilk Cooperative en la barra lateral](subgroups_find_subgroups.png)

<!-- translation-section: invite-to-a-subgroup -->

## Invitar a un subgrupo

Invita a personas a un subgrupo de la misma manera que las invitas a un grupo. Si ya pertenecen a un grupo principal o a otro subgrupo de la misma organización al que tú también perteneces, puedes escribir el nombre de la persona o seleccionar ese grupo como destinatario. Selecciona la etiqueta del grupo destinatario para desplegar la lista de personas y después elimina a quienes no quieras invitar.

<!-- translation-section: simultaneously-invite-people-to-subgroups-and-parent-group -->

### Invitar a personas a los subgrupos y al grupo principal al mismo tiempo

Si usas el botón **Invitar personas** de la pestaña **Integrantes** de tu grupo principal, puedes invitar a personas a varios subgrupos al mismo tiempo marcando las casillas de aquellos a los que quieras que se unan inmediatamente.

![Selección del grupo principal y del subgrupo en el formulario de invitación](group_invite_email_subgroups.png)

<!-- translation-section: administer-a-subgroup -->

## Administrar un subgrupo

Los subgrupos pueden tener admins propios, y los admins de un subgrupo pueden ser distintos de los admins del grupo principal.

Sin embargo, un admin del grupo principal puede asignarse el rol de admin de cualquier subgrupo. Esto permite a los administradores del grupo principal administrar los subgrupos cuando sea necesario.

Ve a la pestaña Subgrupos, busca el subgrupo y haz clic en **Unirse al grupo**.

![Botón Unirse al grupo en un subgrupo cerrado](member_join_subgroup.png)

Una vez que sea miembro del subgrupo, un admin del grupo principal puede asignarse el rol de admin del subgrupo.

![Opción para asignar el rol de admin a un admin del grupo principal](member_make_admin.png)

<!-- translation-section: delete-a-subgroup -->

## Eliminar un subgrupo

Los admins pueden eliminar un subgrupo de la misma manera que eliminas un grupo. Al eliminar un subgrupo, ten cuidado de no eliminar el grupo principal.

Aprende [cómo eliminar grupos](/en/user_manual/groups/deleting_your_group/).
