---
title: Exportación de datos
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: 4ec883363fb166ee
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 3cddc7cbc507e024
  export-data: d227f2b97eada6f7
  export-group-data-as-csv: 58ef10ae9bc05484
  export-group-data-as-html: 1ba66b31b04e237f
  export-group-data-as-json: 6175a23b74bed314
  print-thread-to-pdf: f09555a3ef23a8aa
  import-your-group-data-on-another-loomio-server: fe2a9d83b4dad6f5
title_source: 29049648f87b87f5
title_generated: e5c1f8189ac77167
---

<!-- translation-section: introduction -->

# Copia de seguridad o exportación de datos del grupo

Con la función de exportación de datos del grupo puedes:

- Descargar un archivo con los datos de los miembros para revisar quién pertenece al grupo.
- Descargar el contenido de tu grupo, incluidos los textos de los hilos y las encuestas, para archivarlo o analizarlo.
- Abrir los resultados de las encuestas en una hoja de cálculo o un lenguaje de scripting.
- [Imprimir o guardar un hilo o una encuesta en PDF para archivarlos.](#print-thread-to-pdf)
- Trasladar tu grupo, incluidos todos los usuarios, hilos, encuestas y archivos, a otro servidor de Loomio.

Si en algún momento quieres pasar de los servidores gestionados por Loomio [a tu propio servidor](https://github.com/loomio/loomio), puedes usar esta función.

Si tienes tu propio servidor de Loomio y prefieres dejar de gestionarlo, Loomio ofrece alojamiento gestionado en Estados Unidos, la Unión Europea y Australia. Si quieres migrar tu grupo a uno de estos servidores, [contacta con nosotros](/contact).

[Contacta con nosotros](/contact) si quieres trasladar tu grupo de Loomio del servicio de alojamiento global en loomio.com a uno de nuestros servicios regionales: loomio.eu para Europa o loomio.nz para Australia y Nueva Zelanda.

<!-- translation-section: export-data -->

## Exportar datos

Abre el menú desplegable del grupo haciendo clic en los tres puntos y selecciona **Exportar la data grupal**.

![Acción para exportar los datos del grupo en el menú de Oatmilk Cooperative](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Exportar los datos del grupo como CSV

*Para trabajar con los datos del grupo en una hoja de cálculo, como MS Excel o Google Sheets.*

Loomio prepara el archivo CSV en segundo plano y te envía por correo electrónico un enlace de descarga cuando está listo. El enlace está disponible durante una semana.

<!-- translation-section: export-group-data-as-html -->

### Exportar los datos del grupo como HTML

*Para guardar los datos y archivarlos.*

Loomio prepara el archivo HTML en segundo plano y te envía por correo electrónico un enlace de descarga cuando está listo. El enlace está disponible durante una semana.

<!-- translation-section: export-group-data-as-json -->

### Exportar los datos del grupo como JSON

*Para trasladar los datos de tu grupo a una instancia de Loomio alojada en tu propio servidor.*

Debes ser admin del grupo para exportarlo. La exportación JSON incluye:

- El grupo, sus miembros y las solicitudes de ingreso
- Hilos, comentarios, reacciones, etiquetas, plantillas, notificaciones y registros relacionados de los grupos incluidos
- Encuestas, opciones, votos y conclusiones; una encuesta anónima solo se incluye después de que se haya cerrado
- Subgrupos a los que perteneces
- Subgrupos abiertos y cerrados cuando exportas el grupo principal como admin de ese grupo principal, aunque no pertenezcas a esos subgrupos
- Referencias a archivos e imágenes adjuntos al contenido incluido

La exportación JSON no incluye:

- Subgrupos secretos a los que no perteneces, incluidos sus miembros y su contenido
- Subgrupos pendientes de eliminación
- Encuestas anónimas que no se hayan cerrado
- Hilos directos y encuestas que no pertenecen al grupo

En breve recibirás un correo electrónico con un enlace para descargar el archivo JSON.

<!-- translation-section: print-thread-to-pdf -->

## Imprimir un hilo en PDF

Puede que necesites obtener una copia de un hilo para guardarla en un archivo independiente.

La opción **Imprimir ** del hilo conserva todos los comentarios, encuestas, votos y conclusiones, junto con el formato del hilo.

En el menú del hilo, haz clic en los tres puntos (⋯) y elige **Imprimir **. Loomio generará una página HTML que podrás imprimir o "guardar como PDF" con la herramienta de impresión de tu navegador.

Puedes copiar la página y pegarla en un editor de documentos, un archivo o un repositorio de datos.

![Acción para imprimir la discusión sobre botellas retornables](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importar los datos de tu grupo en otro servidor de Loomio

Para consultar las instrucciones para configurar tu propio servidor de Loomio, visita: https://github.com/loomio/loomio

Si alojas tu propia instalación de Loomio y quieres importar los datos que has exportado:

Copia el archivo .json a la carpeta `import` de la instancia del contenedor:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Accede a la consola de Rails en ejecución:

`docker exec -ti loomio-app rails console`

Llama al servicio:

`GroupExportService.import('/import/your-group-data.json')`
