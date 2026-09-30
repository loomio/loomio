---
title: Votación anónima
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: d5c276b2785919c3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: cdaa1f5c3ca1e179
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 51460c8a6b663aba
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 3dd2c9e6d06debda
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 2ba76a1748304f96
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: b6fce0278a31c93a
  how-anonymous-voting-protects-voters: ba264741f21a2a37
  while-voting-is-open: aeb47d3147a5c126
  votes-cannot-be-changed: b9406960bf2c647c
  why-anonymous-votes-do-not-have-reasons: a319807762129b2e
  results-and-exports: c05b79104e2dea32
  participation-verification: 85afac5e4827a7fb
  reminders: b93ca8540d3f90f0
  what-coordinators-and-administrators-can-see: '03129183e49e7749'
  limits-of-anonymous-voting: 50ffd899e903826d
  questions: f388a65a94d4a089
  can-a-coordinator-see-how-i-voted: 82f2e6c424b31b92
  can-i-see-my-vote-after-submitting-it: 0040f88ee382252e
  can-i-change-or-withdraw-my-vote: 8083eb96543b5839
  will-i-receive-an-email-confirming-my-vote: 9445240ff8fff4e8
  does-a-public-poll-reveal-more-information: 98820e13541ca826
  is-anonymous-voting-suitable-for-every-election: 3386fa7a7b553c73
title_source: 1bc4567506ad4d51
title_generated: 4eeca685a9619ad5
---

<!-- translation-section: introduction -->

# Votación anónima

La votación anónima, también llamada votación secreta, separa el registro de quién ha votado de los votos. Quienes coordinan el sondeo pueden ver quién tenía derecho a votar y, cuando hayan votado al menos tres personas, comprobar quiénes participaron. Quienes usan la aplicación no pueden vincular un voto emitido con la persona que lo emitió.

Esta página explica cómo se protege la votación anónima, qué información se conserva y cuáles son los límites de esa protección.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Cómo protege la votación anónima a quienes votan

Un sondeo anónimo mantiene dos conjuntos de registros separados:

| Registros de participación | Votos emitidos |
| --- | --- |
| Quién tiene derecho a votar | Las opciones seleccionadas o las puntuaciones |
| A quién se invitó y quién lo invitó | El sondeo al que pertenece el voto |
| Si cada persona con derecho a votar ha votado | Ningún nombre ni cuenta de usuario |
| Ninguna opción seleccionada ni puntuación | Ningún vínculo con un registro de participación |

No hay ningún identificador compartido que conecte estos registros. Los votos emitidos tampoco incluyen la hora exacta en que se enviaron, información sobre las invitaciones, motivos escritos, archivos adjuntos ni otros datos que puedan ayudar a identificar a quien votó.

Esta separación se aplica al guardar el voto. No depende solo de ocultar los nombres en la interfaz.

<!-- translation-section: while-voting-is-open -->

## Mientras la votación está abierta

Los resultados permanecen ocultos para todas las personas hasta que se cierra el sondeo. Esto incluye a quienes coordinan el sondeo y a quienes administran el grupo o la instancia mediante la aplicación.

Cuando alguien vota:

- su voto se guarda sin su nombre ni un vínculo con su registro de participación;
- su registro de participación se marca para indicar que ha votado;
- no se crea ningún evento de votación, notificación, correo electrónico, comentario ni entrada de actividad;
- no se devuelve una copia de sus selecciones después de enviarlas; y
- la interfaz solo confirma que se registró su voto.

El registro de participación no guarda la hora exacta en que votó la persona. Los votos emitidos no se ordenan por hora de envío.

<!-- translation-section: votes-cannot-be-changed -->

## Los votos no se pueden cambiar

Cada persona con derecho a votar puede hacerlo una sola vez. Un voto anónimo emitido no se puede consultar, cambiar, retirar ni sustituir, tampoco por parte de quien coordina o administra.

Para que una persona pudiera recuperar o sustituir su voto, tendría que existir un vínculo permanente entre esa persona y el voto. La votación anónima no crea ese vínculo.

Revisa bien tus selecciones antes de enviarlas.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Por qué los votos anónimos no incluyen motivos

Los votos anónimos nuevos no pueden incluir un motivo escrito ni un archivo adjunto. Los motivos pueden contener nombres, datos personales, formas de escribir, menciones u otra información que identifique a quien votó. También facilitarían distinguir los votos individuales dentro del resultado agregado.

Si el hilo permite la discusión, las personas participantes pueden hablar allí sobre el sondeo. Esos comentarios son aportaciones habituales a la discusión, con el nombre de quien los escribe, y no se adjuntan a ningún voto anónimo.

<!-- translation-section: results-and-exports -->

## Resultados y exportaciones

Después de cerrar el sondeo, los resultados se calculan a partir de los votos desvinculados de las personas y se muestran como totales y otros resultados agregados que admita ese tipo de sondeo.

La aplicación no publica identificadores de votos, el orden en que se enviaron ni sus horas de envío. Las exportaciones de sondeos contienen resultados agregados, no una fila por cada voto anónimo. La excepción es una elección STV cerrada, que se puede exportar en formato BLT. Una exportación BLT contiene las clasificaciones de candidaturas necesarias para volver a contar la elección. Cuando varias papeletas tienen la misma clasificación, se agrupan, sin identidades de votantes ni metadatos de las papeletas.

Un sondeo anónimo no se puede reabrir después de cerrarse.

<!-- translation-section: participation-verification -->

## Verificación de la participación

Quienes coordinan el sondeo pueden ver los registros de participación con nombres. Estos siempre muestran quién tenía derecho a votar. Cuando hayan votado al menos tres personas, también muestran si cada una votó, pero nunca cómo votó. Si el sondeo se cierra con menos de tres votos, el estado de participación permanece oculto.

Las demás personas participantes no pueden ver esta información de participación con nombres. Tener acceso a los resultados del sondeo no da acceso a los registros de participación.

Quienes coordinan el sondeo pueden añadir personas con derecho a votar mientras la votación siga abierta, incluso después de que otras personas hayan votado. No se puede retirar de un sondeo anónimo a quienes ya hayan votado.

<!-- translation-section: reminders -->

## Recordatorios

En un sondeo anónimo que dura al menos 24 horas, las personas con derecho a votar que aún no lo hayan hecho reciben un recordatorio automático durante las últimas 24 horas.

El recordatorio se dirige a las personas seleccionadas únicamente a partir de los registros de participación. No examina los votos emitidos ni crea un vínculo con ellos. Si cambia la fecha límite, la comprobación que se hace cada hora usa la fecha límite vigente, sin mantener un recordatorio programado por separado para el sondeo.

Los sondeos cuyo período total de votación es inferior a 24 horas no envían este recordatorio automático.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Qué pueden ver quienes coordinan y administran

Mediante la aplicación, quienes coordinan el sondeo o administran el grupo o la instancia pueden tener acceso a:

- el sondeo y las personas con derecho a votar;
- si cada persona con derecho a votar ha votado, cuando su función les permita acceder a esa información y hayan votado al menos tres personas; y
- los resultados agregados después de que se cierre el sondeo.

No pueden usar las funciones de la aplicación para ver:

- qué selecciones corresponden a una persona;
- los votos individuales ni los patrones de votación;
- cuándo se emitió un voto concreto; ni
- un motivo, archivo adjunto, evento o notificación asociado a un voto emitido.

<!-- translation-section: limits-of-anonymous-voting -->

## Límites de la votación anónima

Estas protecciones impiden que quienes usan la aplicación vinculen un voto emitido con la persona que lo emitió. No ofrecen protección criptográfica frente a quienes operan el sistema y pueden inspeccionar la base de datos, las copias de seguridad, los registros del servidor, la memoria de los procesos, el tráfico de red o una versión modificada de la aplicación.

El resultado también puede revelar información. Si hay pocas personas con derecho a votar, el resultado es unánime, existe una combinación de selecciones poco común o se comparte información fuera del sondeo, puede ser más fácil deducir qué eligió una persona. Quienes votan también pueden optar por identificarse en una discusión fuera del voto que emitieron.

Ten en cuenta cuántas personas pueden votar y la sensibilidad de la decisión al evaluar si la votación anónima de la aplicación es adecuada.

<!-- translation-section: questions -->

## Preguntas

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### ¿Puede un coordinador ver cómo voté?

No. Cuando hayan votado al menos tres personas, un coordinador podrá comprobar si votaste, pero no podrá vincularte con un voto emitido mediante la aplicación. Si han votado menos de tres personas, tu estado de participación permanecerá oculto.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### ¿Puedo ver mi voto después de emitirlo?

No. La aplicación confirma que se registró tu voto y después elimina tus selecciones de la interfaz de votación. No puede recuperar tu voto sin crear el vínculo que la votación anónima busca evitar.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### ¿Puedo cambiar o retirar mi voto?

No. No existe ningún vínculo que permita a la aplicación identificar qué voto emitido debe cambiar o eliminar.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### ¿Recibiré un correo electrónico que confirme mi voto?

No. Al votar, solo aparece una confirmación en pantalla y se actualiza tu registro de participación. No se envía un correo de confirmación ni se crea una notificación o un evento de actividad.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### ¿Una encuesta pública revela más información?

El acceso público puede permitir que otras personas vean la encuesta y sus resultados agregados después del cierre. No permite ver los registros de participación con nombres ni los votos anónimos individuales.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### ¿La votación anónima es adecuada para todas las elecciones?

No. La aplicación separa las identidades de los votos. Las decisiones que requieren protección frente a los operadores del sistema o elecciones criptográficas verificables de forma independiente necesitan un sistema diseñado para esos requisitos.
