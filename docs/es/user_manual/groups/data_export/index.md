---
title: Exportación de datos
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: aa310889d0854550
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 85c71e74107c0f3b
  export-data: 2a5f05b00c92ace1
  export-group-data-as-csv: 2f651efaa83a0177
  export-group-data-as-html: 62e7f80228582296
  export-group-data-as-json: fb81f11a44a7c4bc
  print-thread-to-pdf: f303311479bef81d
  import-your-group-data-on-another-loomio-server: b28edad206709848
title_source: 29049648f87b87f5
title_generated: e5c1f8189ac77167
---

<!-- translation-section: introduction -->

# Copia de seguridad o exportación de datos del grupo

Con la función de exportación de datos del grupo puedes:

- Descargar un archivo con datos de los miembros para auditar quién pertenece al grupo.
- Descargar el contenido de tu grupo, incluido el texto de los hilos y las encuestas, para archivarlo o analizarlo.
- Abrir los resultados de las encuestas en una hoja de cálculo o un lenguaje de programación de scripts.
- [Imprimir o guardar un hilo o una encuesta en PDF para archivarlo.](#print-thread-to-pdf)
- Trasladar tu grupo, incluidos todos los usuarios, hilos, encuestas y archivos, a otro servidor de Loomio.

Si en algún momento quieres pasar de los servidores gestionados por Loomio [a tu propio servidor](https://github.com/loomio/loomio), puedes usar esta función.

Si tienes tu propio servidor de Loomio y prefieres dejar de gestionarlo, Loomio ofrece alojamiento gestionado en Estados Unidos, la Unión Europea y Australia. Si quieres migrar tu grupo a uno de estos servidores, [contacta con nosotros](/contact).

[Contacta con nosotros](/contact) si quieres trasladar tu grupo de Loomio desde el servicio global alojado en loomio.com a uno de nuestros servicios regionales: loomio.eu para Europa o loomio.nz para Australia y Nueva Zelanda.

<!-- translation-section: export-data -->

## Exportar datos

Abre el menú desplegable del grupo haciendo clic en los tres puntos y selecciona **Exportar la data grupal**.

![Acción Exportar la data grupal en el menú de Oatmilk Cooperative](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Exportar datos del grupo en CSV

*Para trabajar con los datos del grupo en una hoja de cálculo, como MS Excel o Google Sheets.*

Loomio prepara el archivo CSV en segundo plano y te envía por correo electrónico un enlace de descarga cuando está listo. El enlace está disponible durante una semana.

<!-- translation-section: export-group-data-as-html -->

### Exportar datos del grupo en HTML

*Para guardar los datos y archivarlos.*

Loomio prepara el archivo HTML en segundo plano y te envía por correo electrónico un enlace de descarga cuando está listo. El enlace está disponible durante una semana.

<!-- translation-section: export-group-data-as-json -->

### Exportar datos del grupo en JSON

*Para trasladar los datos de tu grupo a una instancia de Loomio alojada en tu propio servidor.*

Debes ser admin del grupo para exportarlo. La exportación en JSON incluye:

- El grupo, sus miembros y las solicitudes de ingreso
- Hilos, comentarios, reacciones, etiquetas, plantillas, notificaciones y registros relacionados de los grupos incluidos
- Encuestas, opciones, votos y conclusiones; una encuesta anónima solo se incluye después de haberse cerrado
- Subgrupos a los que perteneces
- Subgrupos abiertos, cerrados y visibles para el grupo principal cuando exportas el grupo principal como admin de ese grupo principal, aunque no pertenezcas a esos subgrupos
- Referencias a los archivos e imágenes adjuntos al contenido incluido

La exportación en JSON no incluye:

- Subgrupos secretos a los que no perteneces, incluidos sus miembros y contenido
- Subgrupos pendientes de eliminación
- Encuestas anónimas que no se han cerrado
- Hilos directos y encuestas que no pertenecen al grupo

En breve recibirás un correo electrónico con un enlace para descargar el archivo JSON.

<!-- translation-section: print-thread-to-pdf -->

## Imprimir un hilo en PDF

Puede que necesites extraer una copia de un hilo para guardarla en un archivo separado.

La opción **Imprimir ** del hilo conserva todos los comentarios, encuestas, votos y conclusiones, además del formato del hilo.

En el hilo, haz clic en el menú de tres puntos (⋯) y elige **Imprimir **. Loomio generará una página HTML que podrás imprimir o "guardar en PDF" con la herramienta de impresión de tu navegador.

Puedes copiar la página para pegarla en un editor de documentos, un archivo o un repositorio de datos.

![Acción Imprimir para la discusión sobre botellas retornables](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importar los datos de tu grupo en otro servidor de Loomio

Para consultar las instrucciones sobre cómo configurar tu propio servidor de Loomio, visita: https://github.com/loomio/loomio

Si alojas tu propia instalación de Loomio y quieres importar los datos que has exportado:

Copia el archivo .json a la carpeta `import` de la instancia del contenedor:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Accede a la consola de Rails en ejecución:

`docker exec -ti loomio-app rails console`

Llama al servicio:

`GroupExportService.import('/import/your-group-data.json')`
