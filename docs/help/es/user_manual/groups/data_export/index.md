---
title: Exportación de datos
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 988679ffd3d29834
  export-data: 9c2fb6ec7c75bcb6
  export-group-data-as-csv: c0845f09bff828f2
  export-group-data-as-html: 659fd5e14956b00e
  export-group-data-as-json: 4c2131f4518b7469
  print-thread-to-pdf: 1a1d0598f4277ba1
  import-your-group-data-on-another-loomio-server: 33d49c6c25be163b
generated:
  introduction: 31081c6041af3dc0
  export-data: c22acf4c89e2f6fa
  export-group-data-as-csv: 39eac860abf465d1
  export-group-data-as-html: 7d28c87dc877d42f
  export-group-data-as-json: d0bdece519da35c1
  print-thread-to-pdf: 27ad86f2b69a4008
  import-your-group-data-on-another-loomio-server: 17b887f468586379
title_source: 29049648f87b87f5
title_generated: e5c1f8189ac77167
---

<!-- translation-section: introduction -->

# Copia de seguridad o exportación de datos del grupo

Con la exportación de datos del grupo puedes:

- Descargar datos de los miembros para auditar quién pertenece al grupo.
- Archivar o analizar los hilos, comentarios y encuestas de tu grupo.
- Abrir los resultados de las encuestas en una hoja de cálculo o un script.
- [Imprimir o guardar un hilo o una encuesta en PDF para tus archivos.](#print-thread-to-pdf)
- Trasladar tu grupo, incluidos sus usuarios, hilos, encuestas y archivos, a otro servidor de Loomio.

Puedes usar esta función para pasar del servicio alojado de Loomio a un [servidor propio](https://github.com/loomio/loomio). Si gestionas tu propio servidor y quieres trasladarte al alojamiento gestionado de Loomio en Estados Unidos, la Unión Europea o Australia, [contacta con nosotros](/contact).

[Contacta con nosotros](/contact) si quieres trasladar un grupo de loomio.com a un servicio regional (loomio.eu para Europa o loomio.nz para Australia y Nueva Zelanda).

<!-- translation-section: export-data -->

## Exportar datos

Solo un admin del grupo puede exportar los datos del grupo. Abre el menú de acciones del grupo y selecciona **Exportar la data grupal**.

![Acción Exportar la data grupal en el menú de Oatmilk Cooperative](group_export_group_data.png)

Loomio prepara la exportación en segundo plano y te envía por correo electrónico un enlace de descarga cuando está lista. El enlace permanece activo durante una semana.

<!-- translation-section: export-group-data-as-csv -->

### Exportar datos del grupo en CSV

Usa CSV para examinar los datos del grupo, incluidos los detalles y la actividad de los miembros, en una hoja de cálculo como Microsoft Excel o Google Sheets.

<!-- translation-section: export-group-data-as-html -->

### Exportar datos del grupo en HTML

Usa HTML para guardar una copia legible de las discusiones y encuestas de tu grupo para archivarlas.

<!-- translation-section: export-group-data-as-json -->

### Exportar datos del grupo en JSON

Usa JSON para trasladar los datos de tu grupo a un servidor propio de Loomio.

La exportación en JSON incluye:

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

<!-- translation-section: print-thread-to-pdf -->

## Imprimir un hilo en PDF

Para guardar un hilo en tus archivos, abre el menú de acciones del hilo y selecciona **Imprimir **. Loomio genera una página HTML con los comentarios, encuestas, votos, conclusiones y formato del hilo. Usa la herramienta de impresión de tu navegador para imprimirla o guardarla como PDF, o copia el contenido en otro documento.

![Acción Imprimir para la discusión sobre botellas retornables](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importar los datos de tu grupo en otro servidor de Loomio

Esta sección está dirigida a administradores que gestionan un servidor propio de Loomio. Para consultar las instrucciones de configuración, visita el [repositorio de Loomio](https://github.com/loomio/loomio).

1. Copia el archivo `.json` a la carpeta `import` del contenedor:

```sh
scp your-group-data.json username@some-domain.org:loomio-deploy/import
```

2. Abre la consola de Rails en el contenedor en ejecución:

```sh
docker exec -ti loomio-app rails console
```

3. Ejecuta el servicio de importación:

```ruby
GroupExportService.import('/import/your-group-data.json')
```
