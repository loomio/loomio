---
title: Gestión de integrantes
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/groups/member_management/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: bc7d2de9abc2ea86
  administering-your-group: 7ae1b105c20977fc
  managing-subgroups: 2e4bdee3283e8ef8
  removing-members: d70807bdd968d594
  leaving-group: 268f0c735b8e46d7
  set-title: eb9a52e3d6c21d43
  member-email-addresses: 0e800419a7bdacc6
generated:
  introduction: f8cdc33bb3a5705b
  administering-your-group: c70addb5b31bbd2c
  managing-subgroups: c8b6a79a182b33ea
  removing-members: 5bab31d20bbb04bb
  leaving-group: 44488130697345cc
  set-title: 00c0c2432fade0f1
  member-email-addresses: 5071f8a179794ef8
title_source: 23ac3a7fe9ee72a2
title_generated: c8901090fb721909
needs_review:
  managing-subgroups: check the interface label "**Secreto**" for "**Secret**"
---

<!-- translation-section: introduction -->

# Gestión de integrantes

Los admins del grupo gestionan a los miembros desde la pestaña **Integrantes** de la página del grupo. Abre el menú de acciones junto a un miembro para añadir un título, convertirlo en admin del grupo, nombrarlo delegado o eliminarlo del grupo.

![Menú de acciones de un miembro en la página de integrantes de Oatmilk Cooperative](member_management.png)

<!-- translation-section: administering-your-group -->

## Administrar tu grupo

Un grupo de Loomio tiene dos roles: **miembro** y **admin del grupo**.

Los admins del grupo pueden añadir y eliminar miembros, gestionar los permisos de los miembros, cambiar la configuración de privacidad del grupo, gestionar las suscripciones, ver las direcciones de correo electrónico de los miembros y exportar los datos del grupo.

La persona que crea un grupo se convierte en admin del grupo de forma predeterminada. Te recomendamos que haya al menos dos admins del grupo para que siempre haya alguien que pueda gestionarlo. Un grupo puede tener tantos admins como necesites.

Para convertir a un miembro en admin del grupo, abre el menú de acciones junto a su nombre en la pestaña **Integrantes** y selecciona **Convertir en admin**.

![Acción Convertir en admin en el menú de un miembro](member_make_admin.png)

<!-- translation-section: managing-subgroups -->

## Gestionar subgrupos

Los admins del grupo principal pueden unirse a cualquier subgrupo no secreto y después convertirse en admins de ese subgrupo.

Selecciona **Unirse al grupo** en la página del subgrupo.

![Botón Unirse al grupo en un subgrupo cerrado de Oatmilk Cooperative](member_join_subgroup.png)

Una vez que seas miembro del subgrupo, abre el menú de acciones junto a tu nombre en la pestaña **Integrantes** del subgrupo y selecciona **Convertir en admin**.

>[!Note]
>Esto no se aplica a los [subgrupos **Secretos**](/en/user_manual/groups/subgroups#permissions).

<!-- translation-section: removing-members -->

## Eliminar miembros

Para eliminar a alguien, abre el menú de acciones junto a su nombre y selecciona **Eliminar del grupo**.

![Acción Eliminar del grupo en el menú de un miembro](member_remove.png)

Cuando se elimina a una persona de un grupo:

- La persona pierde el acceso al grupo y a sus subgrupos, y deja de recibir notificaciones del grupo.
- Sus comentarios y votos existentes se conservan.
- Las encuestas privadas desaparecen de su panel y de su lista de votaciones. Las encuestas públicas siguen siendo accesibles para su lectura, pero la persona no puede votar a menos que vuelva a recibir una invitación. Salir del grupo mientras una encuesta está cerrada no conserva el derecho a votar si se reabre.

Puedes volver a añadir a los miembros eliminados más adelante. Al volver a unirse, recuperan el acceso y sus votos existentes en las encuestas activas.

<!-- translation-section: leaving-group -->

## Salir del grupo

Para salir de un grupo, abre el menú de acciones del grupo y selecciona **Salir del grupo**.

Salir del grupo tiene el mismo efecto sobre el acceso al grupo y a sus subgrupos que la eliminación por parte de un admin del grupo.

![Acción Salir del grupo en el menú de configuración de Oatmilk Cooperative](member_leave_group.png)

<!-- translation-section: set-title -->

## Añadir título

El título de un miembro indica su función en el grupo o la organización a la que representa. Tú o un admin del grupo podéis añadir o cambiar tu título seleccionando **Añadir título del grupo** en el menú de acciones junto a tu nombre en la pestaña **Integrantes**.

![Acción Añadir título del grupo en el menú de un miembro](member_set_title.png)

Puedes tener títulos diferentes en distintos subgrupos.

<!-- translation-section: member-email-addresses -->

## Direcciones de correo electrónico de los miembros

Solo los admins del grupo pueden ver las direcciones de correo electrónico de los miembros.

Para revisar todas las direcciones de correo electrónico de los miembros del grupo y de sus subgrupos, [exporta los datos del grupo](/en/user_manual/groups/data_export) como archivo CSV y ábrelo en Microsoft Excel o Google Sheets.

También puedes buscar miembros por su dirección de correo electrónico en la pestaña **Integrantes** para encontrar y gestionar a una persona concreta.
