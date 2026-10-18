---
title: Recopilar aportaciones privadas
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/discussions/private_submissions/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 1d263d407af586d9
  enable-private-submissions: 3520fbea1fb1267f
  set-up-a-private-submission-process: e9e30dd30ab9d468
  make-a-submission: ac6611a046f0bf9f
  review-submissions: 7014e6ac14301129
generated:
  introduction: 9652dade5ca6b4eb
  enable-private-submissions: 96b958404ab45928
  set-up-a-private-submission-process: a2bd35a0a0babae3
  make-a-submission: '0958b290132dab16'
  review-submissions: 3b71eb1da9a5de14
title_source: e82ab76916d594f4
title_generated: f8f5c4c7e4c2a96e
---

<!-- translation-section: introduction -->

# Recopilar aportaciones privadas

Usa un grupo cerrado para recopilar aportaciones privadas de personas que no son miembros del grupo. Cada aportación se convierte en una discusión independiente que la persona que la envía y el equipo de revisión del grupo pueden usar para intercambiar información, hacer preguntas y registrar una decisión. Quienes envían aportaciones no pueden ver otras discusiones privadas ni otras aportaciones del grupo.

Las candidaturas son un ejemplo claro cuando los datos de las personas candidatas o la lista de candidaturas deben mantenerse privados durante la selección. Una persona puede presentar su propia candidatura o la de otra persona para una elección, un nombramiento, un comité, una junta directiva o un cargo de representación, mientras un comité de selección revisa cada candidatura en una discusión independiente.

Otros usos adecuados en los que las aportaciones no deben ser públicas incluyen:

- Quejas, informes sobre protección de personas, preocupaciones sobre seguridad e informes de incidentes
- Apelaciones y solicitudes para reconsiderar una decisión sobre un caso individual
- Solicitudes de mediación, resolución de conflictos o apoyo personal
- Solicitudes que contienen información personal, financiera o sobre requisitos de acceso, como ayudas por dificultades económicas o becas
- Ofertas en sobre cerrado o propuestas para licitaciones que deben mantenerse privadas durante la evaluación

Este proceso mantiene las aportaciones privadas entre quienes las envían, pero no es anónimo. Quienes envían aportaciones necesitan una cuenta de usuario, y todos los miembros del grupo cerrado pueden verlas. Considera quién pertenece al grupo de revisión antes de usarlo para información sensible.

<!-- translation-section: enable-private-submissions -->

## Habilitar aportaciones privadas

Debes ser admin del grupo o subgrupo donde quieras recopilar aportaciones.

1. Abre el grupo.
2. Selecciona **Configuración ** (o **Más** y luego **Editar la configuración del grupo**).
3. Abre **Permisos**.
4. Activa **Los no miembros pueden iniciar debates**.
5. Guarda la configuración del grupo.

![La pestaña Permisos de la configuración del grupo, con Los no miembros pueden iniciar debates resaltado](non_members_can_start_discussions.png)

Esta opción solo está disponible para grupos **Abierto** y **Cerrado**. Está oculta para grupos **Secreto **. Si no la ves, abre **Privacidad** en la configuración del grupo y cambia **Privacidad del grupo** a **Cerrado** (recomendado para aportaciones privadas) o **Abierto**, y luego vuelve a **Permisos**.

Activar este permiso no hace públicas las discusiones del grupo. Una persona que no sea miembro puede iniciar una nueva discusión y acceder a ella como invitado, pero no puede ver las demás discusiones privadas del grupo.

<!-- translation-section: set-up-a-private-submission-process -->

## Configurar un proceso de aportaciones privadas

1. Crea un subgrupo dedicado al proceso de aportaciones y establece su privacidad en **Cerrado**. Un subgrupo mantiene las aportaciones separadas del resto del trabajo del grupo principal.
2. Añade al comité de selección o a las demás personas responsables de revisar las aportaciones como miembros del subgrupo. Todos los miembros del subgrupo pueden ver todas las aportaciones, así que añade solo a quienes deban tener ese acceso.
3. Crea una [plantilla de discusión](/en/user_manual/discussions/templates) en el subgrupo. Incluye las preguntas y la información que deben proporcionar quienes envían aportaciones. Puedes crear distintas plantillas de discusión para distintos tipos de aportaciones.
4. Si quienes envían aportaciones no deben solicitar unirse al subgrupo, establece la incorporación de miembros en **Solo por invitación**.
5. [Activa las aportaciones privadas](#enable-private-submissions) en los permisos del subgrupo.
6. Prueba el proceso con una cuenta que no sea miembro del subgrupo.
7. Comparte la página del subgrupo con las personas que podrían enviar aportaciones. Deben iniciar sesión en su cuenta de usuario antes de enviar una aportación.

<!-- translation-section: make-a-submission -->

## Enviar una aportación

La persona que envía la aportación abre el subgrupo y selecciona **Iniciar discusión**. Loomio muestra las plantillas de discusión disponibles en el subgrupo. La persona elige la plantilla de discusión adecuada, responde a las preguntas e inicia la discusión.

La discusión pertenece al subgrupo, pero la persona que envía la aportación no se convierte en miembro del subgrupo. Loomio la añade como invitada al hilo de su discusión, lo que le permite ver la discusión y participar en ella con el comité o el equipo de revisión. No puede ver otras discusiones privadas ni otras aportaciones del subgrupo.

<!-- translation-section: review-submissions -->

## Revisar las aportaciones

Los miembros del subgrupo pueden ver todas las discusiones de las aportaciones del subgrupo. Pueden hacer preguntas de seguimiento y usar comentarios, encuestas u otras herramientas de discusión para completar la revisión.

Si otra persona necesita proporcionar información, un miembro del subgrupo con permiso puede invitarla a la discusión de la aportación. Por ejemplo, cuando alguien presenta la candidatura de otra persona, el subgrupo puede invitar a la persona candidata al hilo si necesita participar. La persona invitada se incorpora como invitada sin obtener acceso a las otras discusiones privadas del subgrupo.

Cada persona puede ver la aportación que ha enviado, pero no puede ver las otras discusiones privadas ni las otras aportaciones del subgrupo. Desactiva **Los no miembros pueden iniciar debates** cuando termine el plazo para enviar aportaciones. Las discusiones existentes y el acceso de las personas invitadas se mantienen sin cambios.
