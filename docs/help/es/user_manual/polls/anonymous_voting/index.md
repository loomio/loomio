---
title: Votación anónima
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: ffcecd2f4297c47d
  how-anonymous-voting-protects-voters: 3b757a1b4a7bda96
  while-voting-is-open: aafc698ee8108194
  votes-cannot-be-changed: 3a99e6c3f48e10ee
  why-anonymous-votes-do-not-have-reasons: 4027d6c1fbf4d29c
  results-and-exports: 5c10ab43a5f890b4
  participation-verification: e77ece0fc0d6cd73
  reminders: f711a180ae7c948f
  what-coordinators-and-administrators-can-see: d873cd48677fc324
  limits-of-anonymous-voting: 9ab54b74a4716e19
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: bfa1baf48f41cdd1
  can-i-see-my-vote-after-submitting-it: 435010e0c2ecf488
  can-i-change-or-withdraw-my-vote: 676d5401bf4d73cc
  will-i-receive-an-email-confirming-my-vote: 9660f10e8ffb9f9c
  does-a-public-poll-reveal-more-information: '087defb00bb8b99f'
  is-anonymous-voting-suitable-for-every-election: 9fae56c0661f0ec9
generated:
  introduction: 438342099e4da085
  how-anonymous-voting-protects-voters: d17e5aced705bb74
  while-voting-is-open: d16361422e6d08d3
  votes-cannot-be-changed: 9371bf1239c66be0
  why-anonymous-votes-do-not-have-reasons: 93f12eb7e26d5e91
  results-and-exports: 5324f44c2363f79e
  participation-verification: 98b00596ee430e70
  reminders: cc171b7029e13573
  what-coordinators-and-administrators-can-see: 71916806c2fe1116
  limits-of-anonymous-voting: 789728a7cb9b1580
  questions: f388a65a94d4a089
  can-a-coordinator-see-how-i-voted: 07e25d63fdee75cb
  can-i-see-my-vote-after-submitting-it: f17b4682fbecb17e
  can-i-change-or-withdraw-my-vote: 1cc1dbf0c4cec47f
  will-i-receive-an-email-confirming-my-vote: 6186215f8fe091db
  does-a-public-poll-reveal-more-information: 69cb502e59b7e419
  is-anonymous-voting-suitable-for-every-election: d503493baee946d8
title_source: 1bc4567506ad4d51
title_generated: 4eeca685a9619ad5
---

<!-- translation-section: introduction -->

# Votación anónima

La votación anónima, también conocida como votación a ciegas, separa el registro de quién votó de los votos en sí. Una vez que se cierra la encuesta, cualquier persona que pueda ver los resultados puede ver quién participó, pero nadie que use Loomio puede vincular un voto con la persona que lo emitió.

Esta página explica cómo funciona la votación anónima, qué información se conserva y los límites de esta protección.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Cómo protege la votación anónima a los votantes

Una encuesta anónima mantiene dos conjuntos de registros separados:

| Registros de participación | Votos enviados |
| --- | --- |
| Quién puede votar | Las opciones o puntuaciones seleccionadas |
| Quién recibió una invitación y de quién | La encuesta a la que pertenece el voto |
| Si cada persona con derecho a voto ha votado | Sin nombre ni cuenta de usuario |
| Sin opciones ni puntuaciones seleccionadas | Sin vínculo con un registro de participación |

No hay ningún identificador compartido que conecte estos registros. Los votos enviados tampoco incluyen las horas de envío, los detalles de las invitaciones, los motivos de los votos, los archivos adjuntos ni otros metadatos que puedan identificar a un votante.

Esta separación se aplica al guardar el voto; no depende únicamente de ocultar los nombres en la interfaz.

<!-- translation-section: while-voting-is-open -->

## Mientras la votación está abierta

Los resultados permanecen ocultos para todo el mundo hasta que se cierra la encuesta, incluidos los admins del hilo, los admins del grupo y los admins de la instancia.

Cuando alguien vota:

- el voto se almacena sin el nombre ni el registro de participación de esa persona;
- el registro de participación se marca para indicar que esa persona ha votado;
- no se crea ningún evento de voto, notificación, correo electrónico, comentario ni entrada de actividad;
- no se devuelve ninguna copia de las selecciones después del envío; y
- la pantalla solo confirma que el voto se ha registrado.

El registro de participación no almacena la hora exacta en que una persona votó, y los votos enviados no se ordenan por hora de envío.

<!-- translation-section: votes-cannot-be-changed -->

## Los votos no se pueden cambiar

Cada persona con derecho a voto puede votar una vez. Un voto anónimo enviado no se puede consultar, cambiar, retirar ni sustituir, ni siquiera por un admin.

Permitir que una persona recupere o sustituya un voto requeriría un vínculo entre esa persona y el voto, algo que la votación anónima evita de forma deliberada.

Revisa tus selecciones con atención antes de enviarlas.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Por qué los votos anónimos no tienen motivos

Los votos anónimos no pueden incluir un motivo ni un archivo adjunto. Los motivos pueden contener nombres, datos personales, patrones de escritura o menciones que identifiquen al votante, y podrían facilitar que se distingan los votos individuales entre los resultados.

Los participantes pueden seguir comentando la encuesta en el hilo correspondiente. Esos comentarios son aportaciones habituales con el nombre de quien los escribe y no están vinculados a un voto anónimo.

<!-- translation-section: results-and-exports -->

## Resultados y exportaciones

Una vez que se cierra la encuesta, Loomio calcula los resultados a partir de los votos desvinculados y muestra los totales correspondientes a ese tipo de encuesta.

Loomio no publica los identificadores de los votos, el orden de envío ni las horas de envío. Las exportaciones de encuestas solo contienen resultados agregados en lugar de una fila por cada voto. La única excepción es una elección STV cerrada, que se puede exportar en formato BLT para volver a contar los votos. Una exportación BLT enumera los órdenes de preferencia de los candidatos (agrupados cuando varias papeletas coinciden), sin identidades de votantes ni metadatos de las papeletas.

Una encuesta anónima no se puede reabrir después de cerrarse.

<!-- translation-section: participation-verification -->

## Quién participó

Una vez que se cierra una encuesta anónima, cualquier persona que pueda ver los resultados puede ver quién participó. Nadie puede ver esta información mientras la votación esté abierta.

Selecciona **Ver votos** para ver la lista. Siempre muestra quién tenía derecho a voto y nunca muestra cómo votó cada persona ni cuándo. Solo muestra si cada persona votó cuando han participado suficientes personas: al menos el quórum de la encuesta, si está establecido; de lo contrario, al menos la mitad de los votantes con derecho a voto, y nunca menos de tres votos.

Los miembros del grupo y los votantes de la encuesta también ven cuándo se unió cada persona al grupo y quién la invitó. Los admins del grupo también ven las direcciones de correo electrónico para distinguir a las personas con el mismo nombre.

Como todas las personas que pueden ver los resultados pueden ver quién votó, un resultado en el que todos los votos coinciden puede revelar cómo votaron las personas. Por ejemplo, si todos los votos son De acuerdo, todas las personas que votaron estuvieron de acuerdo.

Los admins pueden añadir personas con derecho a voto mientras la votación siga abierta, incluso después de que otras personas hayan votado. No se puede eliminar de una encuesta anónima a los votantes que ya forman parte de ella.

<!-- translation-section: reminders -->

## Recordatorios

En una encuesta anónima que dure al menos 24 horas, las personas con derecho a voto que no hayan votado reciben un recordatorio automático durante las últimas 24 horas.

Loomio selecciona a las personas destinatarias únicamente a partir de los registros de participación, sin consultar los votos enviados.

Las encuestas con un periodo de votación inferior a 24 horas no envían este recordatorio automático.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Qué pueden ver los admins

A través de la aplicación, un admin del hilo, un admin del grupo o un admin de la instancia puede tener acceso a:

- la encuesta y los votantes con derecho a voto;
- si cada persona con derecho a voto ha votado (cuando el rol permita el acceso y hayan votado suficientes personas); y
- los resultados agregados después de que se cierre la encuesta.

No pueden usar la aplicación para ver:

- qué selecciones pertenecen a una persona;
- votos individuales o patrones de votación;
- cuándo se envió un voto; o
- un motivo, archivo adjunto, evento o notificación vinculado a un voto.

<!-- translation-section: limits-of-anonymous-voting -->

## Límites de la votación anónima

La votación anónima impide que los usuarios de Loomio vinculen un voto con un votante. No ofrece protección criptográfica frente a un operador del servidor que pueda inspeccionar la base de datos, las copias de seguridad, los registros del servidor, la memoria de los procesos, el tráfico de red o el código modificado.

Los propios resultados también pueden dar pistas. Un grupo pequeño, una votación unánime, una combinación única de selecciones o los comentarios compartidos fuera de la encuesta pueden facilitar que se deduzca el voto de una persona.

Considera el tamaño del grupo y la sensibilidad de la decisión antes de confiar en la votación anónima a nivel de la aplicación.

<!-- translation-section: questions -->

## Preguntas

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### ¿Puede alguien ver cómo voté?

No. Nadie que use Loomio puede vincularte con tu voto. Una vez que hayan votado suficientes personas, cualquier persona que pueda ver los resultados podrá ver si participaste. Antes de alcanzar ese umbral, incluso la información sobre si votaste permanece oculta.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### ¿Puedo ver mi voto después de enviarlo?

No. Loomio confirma que tu voto se ha registrado y elimina tus selecciones de la pantalla. No puede recuperar tu voto sin crear el vínculo que la votación anónima evita.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### ¿Puedo cambiar o retirar mi voto?

No. Como no existe ningún vínculo entre tú y tu voto, Loomio no puede identificar qué voto cambiar o eliminar.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### ¿Recibiré un correo electrónico de confirmación de mi voto?

No. Al votar, solo se muestra una confirmación en pantalla y se actualiza tu registro de participación. No se envía ningún correo electrónico ni se crea ninguna notificación o entrada de actividad.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### ¿Una encuesta pública revela más información?

Cuando se cierra una encuesta pública, cualquier persona puede ver los resultados y quién participó. No puede ver los votos individuales ni los detalles de pertenencia al grupo o de las invitaciones.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### ¿La votación anónima es adecuada para todas las elecciones?

No. Separa a los votantes de los votos dentro de la aplicación. Las elecciones que requieren protección frente a quienes operan el servidor o una verificación criptográfica independiente necesitan un sistema diseñado para esos requisitos.
