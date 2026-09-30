---
title: Exportación de datos
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: 4ec883363fb166ee
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 9c692aed3ac8693a
  export-data: f4d1c607f4eee0fa
  export-group-data-as-csv: 58ef10ae9bc05484
  export-group-data-as-html: 13085db3719df15e
  export-group-data-as-json: bd1b60236555affc
  print-thread-to-pdf: 6d25cdabad673768
  import-your-group-data-on-another-loomio-server: 0be6acc9b528d5ec
title_source: 29049648f87b87f5
title_generated: e5c1f8189ac77167
---

<!-- translation-section: introduction -->

# Copia de seguridad o exportación de los datos del grupo

Con la función de exportación de datos del grupo puedes:

- Descargar un archivo con los datos de los miembros para revisar quién pertenece al grupo.
- Descargar el contenido del grupo, incluido el texto de los hilos y sondeos, para archivarlo o analizarlo.
- Abrir los resultados de los sondeos en una hoja de cálculo o con un lenguaje de programación.
- [Imprimir un hilo o sondeo, o guardarlo como PDF para archivarlo.](#print-thread-to-pdf)
- Trasladar tu grupo, con todos sus usuarios, hilos, sondeos y archivos, a otro servidor de Loomio.

Si alguna vez quieres pasar de los servidores gestionados por Loomio [a uno propio](https://github.com/loomio/loomio), puedes usar esta función.

Si tienes tu propio servidor de Loomio y prefieres dejar de administrarlo, Loomio ofrece alojamiento gestionado en Estados Unidos, la Unión Europea y Australia. Si quieres trasladar tu grupo a uno de estos servidores, [ponte en contacto con nosotros](/contact).

[Ponte en contacto con nosotros](/contact) si quieres trasladar tu grupo del servicio global de Loomio en loomio.com a uno de nuestros servicios regionales: loomio.eu para Europa o loomio.nz para Australia y Nueva Zelanda.

<!-- translation-section: export-data -->

## Exportar datos

Haz clic en los tres puntos para abrir el menú del grupo y selecciona **Exportar la data grupal**.

![Opción Exportar la data grupal en el menú de la Cooperativa Oatmilk](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Exportar los datos del grupo como CSV

*Para trabajar con los datos del grupo en una hoja de cálculo, como MS Excel o Google Sheets.*

Loomio prepara el archivo CSV en segundo plano y te envía por correo electrónico un enlace de descarga cuando está listo. El enlace está disponible durante una semana.

<!-- translation-section: export-group-data-as-html -->

### Exportar los datos del grupo como HTML

*Para guardar los datos en un archivo.*

Loomio prepara el archivo HTML en segundo plano y te envía por correo electrónico un enlace de descarga cuando está listo. El enlace está disponible durante una semana.

<!-- translation-section: export-group-data-as-json -->

### Exportar los datos del grupo como JSON

*Para trasladar los datos del grupo a una instancia de Loomio alojada en tu propio servidor.*

Debes ser administrador del grupo para exportarlo. La exportación JSON incluye:

- El grupo, sus miembros y las solicitudes de ingreso
- Hilos, comentarios, reacciones, etiquetas, plantillas, notificaciones y registros relacionados de los grupos incluidos
- Sondeos, opciones, votos y conclusiones; los sondeos anónimos solo se incluyen después de cerrarse
- Los subgrupos a los que perteneces
- Los subgrupos abiertos y cerrados cuando exportas el grupo principal como administrador de ese grupo, aunque no pertenezcas a esos subgrupos
- Referencias a los archivos e imágenes adjuntos al contenido incluido

La exportación JSON no incluye:

- Los subgrupos secretos a los que no perteneces, incluidos sus miembros y contenido
- Los subgrupos pendientes de eliminación
- Los sondeos anónimos que aún no se han cerrado
- Los hilos y sondeos directos que no pertenecen al grupo

En breve recibirás un correo electrónico con un enlace para descargar el archivo JSON.

<!-- translation-section: print-thread-to-pdf -->

## Imprimir un hilo en PDF

Puedes guardar una copia de un hilo en un archivo independiente.

La opción **Imprimir ** conserva todos los comentarios, sondeos, votos y conclusiones, además del formato del hilo.

En el menú del hilo, haz clic en los tres puntos (⋯) y elige **Imprimir **. Loomio generará una página HTML que podrás imprimir o «guardar como PDF» con la función de impresión del navegador.

Puedes copiar la página y pegarla en un editor de documentos, un archivo o un repositorio de datos.

![Opción Imprimir para la discusión sobre botellas retornables](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importar los datos de tu grupo en otro servidor de Loomio

Para obtener instrucciones sobre cómo configurar tu propio servidor de Loomio, visita: https://github.com/loomio/loomio

Si alojas tu propia instancia de Loomio y quieres importar los datos exportados:

Copia el archivo .json en la carpeta `import` de la instancia del contenedor:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Accede a la consola Rails en ejecución:

`docker exec -ti loomio-app rails console`

Llama al servicio:

`GroupExportService.import('/import/your-group-data.json')`
