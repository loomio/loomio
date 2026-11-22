---
title: Dirección de correo electrónico
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/groups/email/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: '03039e0babf5a9b6'
  preventing-unauthorized-emails: f4b8d2eaf0d79f01
generated:
  introduction: 83f1f1f35d9eb2af
  preventing-unauthorized-emails: 07e114cd0911f70a
title_source: f2488fd4ef4adbc6
title_generated: 8bd6a0c76042ef57
---

<!-- translation-section: introduction -->

# Envía un correo electrónico para iniciar un hilo en tu grupo

Cada grupo de Loomio tiene su propia dirección de correo electrónico. Puedes enviar o reenviar un correo a esta dirección para iniciar un nuevo hilo en el grupo.

Puedes encontrar la dirección de correo electrónico del grupo en la página del grupo:

![Ubicación de la dirección de correo electrónico en la página del grupo](email_email_button.png)

Cuando envías un correo a esta dirección, Loomio crea un nuevo hilo. El asunto del correo se convierte en el título del hilo, el cuerpo se convierte en la descripción del hilo y los archivos adjuntos se añaden al hilo.

Loomio utiliza la dirección del campo "De" del correo para identificar al remitente como miembro del grupo y establecerlo como autor del hilo.

<!-- translation-section: preventing-unauthorized-emails -->

## Evitar correos no autorizados

Para evitar que personas que no son miembros inicien hilos, Loomio exige que la dirección del campo "De" de un correo entrante coincida con la dirección de correo electrónico de un miembro del grupo.

Si un miembro envía un correo desde una dirección no reconocida, Loomio retiene el correo y avisa a los admins del grupo. Un admin del grupo puede aprobar el correo y añadir la dirección como alias de ese miembro, o rechazar los correos posteriores de esa dirección.

Una vez añadido el alias, los futuros correos de esa dirección inician hilos inmediatamente.

![Botones para aprobar y rechazar un correo de una dirección no reconocida](email_unreleased_emails.png)
