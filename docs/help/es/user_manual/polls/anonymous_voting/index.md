---
title: Votación anónima
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 2b9b7da01da020b3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: 87bc3647be4bbfb8
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 07faa9f646665b64
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 574fc18f3a9871c3
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 27acfa7744a0790d
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: 610c51e5cc6e6692
  how-anonymous-voting-protects-voters: 89da0ae00ae0dbea
  while-voting-is-open: d0255036755b0838
  votes-cannot-be-changed: e6cb0b971146e775
  why-anonymous-votes-do-not-have-reasons: ab05152c47bebbf0
  results-and-exports: '029a62ade78bf70c'
  participation-verification: f30a65e042065492
  reminders: 149cb032b2a5b4ee
  what-coordinators-and-administrators-can-see: 707fbb794f8840d0
  limits-of-anonymous-voting: 0f62aeac5b357704
  questions: f388a65a94d4a089
  can-a-coordinator-see-how-i-voted: a2d1819c59840142
  can-i-see-my-vote-after-submitting-it: 131cd0b0aee99b64
  can-i-change-or-withdraw-my-vote: b36f63aa0a6208ae
  will-i-receive-an-email-confirming-my-vote: bb743905df8e6df0
  does-a-public-poll-reveal-more-information: 69cb502e59b7e419
  is-anonymous-voting-suitable-for-every-election: 9a4f2e2964470923
title_source: 1bc4567506ad4d51
title_generated: 4eeca685a9619ad5
---

<!-- translation-section: introduction -->

# Votación anónima

La votación anónima, también conocida como votación a ciegas, separa el registro de quién ha votado de los votos en sí. Una vez que se cierra la encuesta, cualquier persona que pueda ver los resultados puede ver quién participó. Nadie que use Loomio puede vincular un voto enviado con la persona que lo envió.

Esta página explica las protecciones que ofrece la votación anónima, la información que se conserva y los límites de esta garantía.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Cómo protege la votación anónima a los votantes

Una encuesta anónima mantiene dos conjuntos de registros separados:

| Registros de participación | Votos enviados |
| --- | --- |
| Quién puede votar | Las opciones o puntuaciones seleccionadas |
| Quién recibió una invitación y de quién | La encuesta a la que pertenece el voto |
| Si cada persona con derecho a voto ha votado | Sin nombre ni cuenta de usuario |
| Sin opciones ni puntuaciones seleccionadas | Sin vínculo con un registro de participación |

No hay ningún identificador compartido que conecte estos registros. Los votos enviados tampoco incluyen la hora real de envío, la información de la invitación, los motivos escritos, los archivos adjuntos ni otros metadatos que puedan ayudar a identificar a un votante.

Esta separación se aplica al almacenar el voto. No depende únicamente de ocultar los nombres en la interfaz.

<!-- translation-section: while-voting-is-open -->

## Mientras la votación está abierta

Los resultados permanecen ocultos para todo el mundo hasta que se cierra la encuesta. Esto incluye a los coordinadores de la encuesta, los administradores del grupo y los administradores de la instancia que usan la aplicación.

Cuando alguien vota:

- el voto enviado se almacena sin el nombre ni el registro de participación de esa persona;
- el registro de participación se marca para indicar que esa persona ha votado;
- no se crea ningún evento de voto, notificación, correo electrónico, comentario ni entrada de actividad;
- no se devuelve ninguna copia de las selecciones después del envío; y
- la interfaz solo confirma que el voto se ha registrado.

El registro de participación no almacena la hora exacta en que la persona votó. Los votos enviados no se ordenan por hora de envío.

<!-- translation-section: votes-cannot-be-changed -->

## Los votos no se pueden cambiar

Cada persona con derecho a voto puede votar una vez. Un voto anónimo enviado no se puede consultar, cambiar, retirar ni sustituir, ni siquiera por un coordinador o administrador.

Permitir que una persona recupere o sustituya su voto requeriría un vínculo persistente entre esa persona y el voto. La votación anónima no crea ese vínculo de forma deliberada.

Revisa tus selecciones con atención antes de enviarlas.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Por qué los votos anónimos no tienen motivos

Los nuevos votos anónimos no pueden incluir un motivo escrito ni un archivo adjunto. Los motivos pueden contener nombres, datos personales, patrones de escritura, menciones u otra información que identifique al votante. También facilitarían distinguir los votos individuales del resultado agregado.

Los participantes pueden seguir comentando la encuesta en su hilo cuando la discusión esté disponible. Esos comentarios son aportaciones habituales a la discusión con el nombre de quien los escribe y no están vinculados a un voto anónimo.

<!-- translation-section: results-and-exports -->

## Resultados y exportaciones

Una vez que se cierra la encuesta, los resultados se calculan a partir de los votos desvinculados y se muestran como totales y otros resultados agregados que admite el tipo de encuesta.

La aplicación no publica los identificadores de los votos, el orden de envío ni las horas de envío. Las exportaciones de encuestas contienen resultados agregados en lugar de una fila por cada voto anónimo, con la excepción de que una elección STV cerrada se puede exportar en formato BLT. Una exportación BLT contiene los órdenes de preferencia de los candidatos necesarios para volver a contar los votos de la elección, agrupados cuando varias papeletas tienen el mismo orden de preferencia, sin identidades de votantes ni metadatos de las papeletas.

Una encuesta anónima no se puede reabrir después de cerrarse.

<!-- translation-section: participation-verification -->

## Quién participó

Una vez que se cierra una encuesta anónima, cualquier persona que pueda ver los resultados puede ver quién participó. Nadie puede ver esta información mientras la votación esté abierta.

Selecciona **Ver votos** para ver la lista. Siempre muestra quién tenía derecho a voto. Solo muestra si cada persona votó cuando han votado suficientes personas. Esto significa alcanzar el quórum de la encuesta, si lo tiene; de lo contrario, la mitad de los votantes con derecho a voto, y nunca menos de tres votos. La lista nunca muestra cómo votó cada persona ni cuándo.

Los miembros del grupo y los votantes de la encuesta también ven cuándo se unió cada persona al grupo y quién la invitó. Los admins del grupo también ven las direcciones de correo electrónico para distinguir a las personas con el mismo nombre.

Como todas las personas que pueden ver los resultados pueden ver quién votó, un resultado en el que todos los votos coinciden puede revelar cómo votaron las personas. Por ejemplo, si todos los votos son De acuerdo, todas las personas que votaron estuvieron de acuerdo.

Los coordinadores pueden añadir personas con derecho a voto mientras la votación siga abierta, incluso después de que otras personas hayan votado. No se puede eliminar de una encuesta anónima a los votantes que ya forman parte de ella.

<!-- translation-section: reminders -->

## Recordatorios

En una encuesta anónima que dure al menos 24 horas, las personas con derecho a voto que no hayan votado reciben un recordatorio automático durante las últimas 24 horas.

Las personas que reciben el recordatorio se seleccionan únicamente a partir de los registros de participación. No se examinan los votos enviados ni se crea un vínculo con ellos. Si cambia el plazo, la comprobación de recordatorios que se realiza cada hora usa el plazo actual, sin mantener un recordatorio programado por separado para la encuesta.

Las encuestas con un periodo total de votación inferior a 24 horas no envían este recordatorio automático.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Qué pueden ver los coordinadores y administradores

A través de la aplicación, un coordinador de la encuesta, un administrador del grupo o un administrador de la instancia puede tener acceso a:

- la encuesta y los votantes con derecho a voto;
- si cada persona con derecho a voto ha votado, cuando su rol permita el acceso y hayan votado suficientes personas; y
- los resultados agregados después de que se cierre la encuesta.

No pueden usar las funciones de la aplicación para ver:

- qué selecciones pertenecen a una persona;
- votos individuales o patrones de votación;
- cuándo se envió un voto concreto; o
- un motivo, archivo adjunto, evento o notificación asociado a un voto enviado.

<!-- translation-section: limits-of-anonymous-voting -->

## Límites de la votación anónima

Estas protecciones impiden que los usuarios de la aplicación vinculen un voto enviado con su votante. No ofrecen protección criptográfica frente a un operador que pueda inspeccionar la base de datos, las copias de seguridad, los registros del servidor, la memoria de los procesos, el tráfico de red o una versión modificada de la aplicación.

El propio resultado también puede revelar información. Un número reducido de votantes, un resultado unánime, una combinación distintiva de selecciones o información compartida fuera de la encuesta pueden facilitar que se deduzcan las elecciones de una persona. Los votantes también pueden optar por identificarse en la discusión, al margen del voto enviado.

Considera el número de votantes y la sensibilidad de la decisión al decidir si la votación anónima a nivel de la aplicación es adecuada.

<!-- translation-section: questions -->

## Preguntas

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### ¿Puede alguien ver cómo voté?

No. Una vez que hayan votado suficientes personas, quienes puedan ver los resultados podrán ver si votaste. Nadie puede vincularte con un voto enviado a través de la aplicación. Hasta entonces, la información sobre si votaste permanece oculta.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### ¿Puedo ver mi voto después de enviarlo?

No. La aplicación confirma que tu voto se ha registrado y luego elimina las opciones seleccionadas de la interfaz de votación. No puede recuperar tu voto sin crear el vínculo que la votación anónima está diseñada para evitar.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### ¿Puedo cambiar o retirar mi voto?

No. No existe ningún vínculo que permita a la aplicación identificar qué voto enviado debe cambiar o eliminar.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### ¿Recibiré un correo electrónico de confirmación de mi voto?

No. Al votar, solo se muestra una confirmación en pantalla y se actualiza tu registro de participación. No se envía ningún correo electrónico de confirmación ni se crea ninguna notificación o evento de actividad.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### ¿Una encuesta pública revela más información?

Cuando se cierra una encuesta pública, cualquier persona puede ver los resultados y quién participó. No puede ver los votos individuales ni los detalles de pertenencia al grupo o de las invitaciones.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### ¿La votación anónima es adecuada para todas las elecciones?

No. Separa las identidades de los votos dentro de la aplicación. Las decisiones que requieren protección frente a quienes operan el sistema o elecciones criptográficas verificables de forma independiente necesitan un sistema diseñado para esos requisitos.
