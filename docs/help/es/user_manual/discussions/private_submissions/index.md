---
title: Recopilar aportaciones privadas
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/discussions/private_submissions/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 4ec7d13335b07a50
  enable-private-submissions: 013e00c5ac4d7a7e
  set-up-a-private-submission-process: cb0361b8044af3e3
  make-a-submission: cbd92f58d6a8840e
  review-submissions: 267be9e3c705c196
generated:
  introduction: 5b7041cb79df535a
  enable-private-submissions: 353f35d5cbaede74
  set-up-a-private-submission-process: d29b79748326c05f
  make-a-submission: 3bdd0fbad5d03a32
  review-submissions: cdce4add6e3589b3
title_source: e82ab76916d594f4
title_generated: f8f5c4c7e4c2a96e
---

<!-- translation-section: introduction -->

# Recopilar aportaciones privadas

Usa un grupo cerrado para recopilar aportaciones privadas de personas ajenas al grupo. Cada aportación se convierte en una discusión independiente donde la persona que la envía y el equipo de revisión pueden intercambiar información, hacer preguntas y registrar una decisión. Quienes envían aportaciones no pueden ver otras discusiones privadas ni otras aportaciones del grupo.

Esto resulta útil para las candidaturas cuando los datos de las personas candidatas o la lista de candidaturas deben mantenerse privados durante la selección. Una persona puede presentar su propia candidatura o la de otra persona para una elección, un comité o un cargo en una junta directiva, mientras el comité de selección revisa cada candidatura en un hilo independiente.

Otros usos habituales incluyen:

- Quejas, informes sobre protección de personas, preocupaciones sobre seguridad e informes de incidentes
- Apelaciones y solicitudes para reconsiderar una decisión sobre un caso individual
- Solicitudes de mediación, resolución de conflictos o apoyo personal
- Solicitudes con datos personales, financieros o sobre requisitos de acceso, como ayudas por dificultades económicas o becas
- Ofertas en sobre cerrado o propuestas para licitaciones que deben mantenerse privadas durante la evaluación

Este proceso mantiene las aportaciones privadas entre quienes las envían, pero no es anónimo. Quienes envían aportaciones necesitan una cuenta de usuario, y todos los miembros del grupo cerrado pueden ver todas las aportaciones. Revisa quién pertenece al grupo antes de usarlo para información sensible.

<!-- translation-section: enable-private-submissions -->

## Habilitar aportaciones privadas

Debes ser admin del grupo o subgrupo donde quieras recopilar aportaciones.

1. Abre el grupo.
2. Abre **Configuración ** y selecciona **Editar la configuración del grupo**.
3. Abre **Permisos**.
4. Activa **Los no miembros pueden iniciar debates**.
5. Guarda la configuración del grupo.

![La pestaña Permisos de la configuración del grupo, con Los no miembros pueden iniciar debates resaltado](non_members_can_start_discussions.png)

Esta opción solo aparece para grupos **Abierto** y **Cerrado**, no para grupos **Secreto**. Si no la ves, abre **Privacidad** en la configuración del grupo, establece **Privacidad del grupo** en **Cerrado** (recomendado para aportaciones privadas) o **Abierto**, y vuelve a **Permisos**.

Activar este permiso no hace públicas las discusiones del grupo. Una persona que no sea miembro puede iniciar una discusión y acceder a ese hilo como invitada, pero no puede ver otras discusiones privadas del grupo.

<!-- translation-section: set-up-a-private-submission-process -->

## Configurar un proceso de aportaciones privadas

1. Crea un subgrupo dedicado a las aportaciones y establece su privacidad en **Cerrado**. Un subgrupo mantiene las aportaciones separadas del resto del trabajo del grupo principal.
2. Añade al equipo de revisión o al comité de selección como miembros del subgrupo. Todos los miembros del subgrupo pueden ver todas las aportaciones, así que añade solo a quienes necesiten acceso.
3. Crea una o más [plantillas de discusión](/en/user_manual/discussions/templates) en el subgrupo con las preguntas y los datos que deben proporcionar quienes envían aportaciones.
4. Establece la incorporación de miembros en **Solo por invitación** si quienes envían aportaciones no deben solicitar unirse al subgrupo.
5. [Activa las aportaciones privadas](#enable-private-submissions) en los permisos del subgrupo.
6. Prueba el proceso con una cuenta que no sea miembro del subgrupo.
7. Comparte la página del subgrupo con quienes vayan a enviar aportaciones. Deben iniciar sesión en una cuenta de usuario antes de enviarlas.

<!-- translation-section: make-a-submission -->

## Enviar una aportación

La persona que envía la aportación abre el subgrupo y selecciona **Nuevo hilo**. Loomio muestra las plantillas de discusión del subgrupo. La persona elige la plantilla adecuada, responde a las preguntas e inicia la discusión.

La discusión pertenece al subgrupo, y Loomio añade a la persona que envía la aportación como invitada a ese hilo, sin convertirla en miembro del subgrupo. Puede participar en su propio hilo con el equipo de revisión, pero no puede ver otras discusiones privadas ni otras aportaciones del subgrupo.

<!-- translation-section: review-submissions -->

## Revisar las aportaciones

Los miembros del subgrupo pueden ver todos los hilos de aportaciones del subgrupo. Pueden hacer preguntas de seguimiento y usar comentarios, encuestas u otras herramientas para completar la revisión.

Si otra persona necesita aportar su opinión, un miembro del subgrupo con permiso puede invitarla a ese hilo. Por ejemplo, después de que alguien presente la candidatura de otra persona, el comité puede invitar a la persona candidata al hilo. La persona invitada se incorpora como invitada sin obtener acceso a otras discusiones privadas del subgrupo.

Cuando termine el plazo para enviar aportaciones, desactiva **Los no miembros pueden iniciar debates**. Los hilos de aportaciones existentes y el acceso de las personas invitadas se mantienen sin cambios.
