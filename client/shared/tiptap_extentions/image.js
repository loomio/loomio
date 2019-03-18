import { Node, Plugin } from 'tiptap'
import FileUploader from 'shared/services/file_uploader'
import {placeholderPlugin, findPlaceholder} from 'shared/tiptap_extentions/placeholder_plugin.js'

export default class Image extends Node {
  get name() {
    return 'image'
  }

  get schema() {
    return {
      inline: true,
      attrs: {
        src: {},
        alt: {
          default: null,
        },
        title: {
          default: null,
        },
      },
      group: 'inline',
      draggable: true,
      parseDOM: [
        {
          tag: 'img[src]',
          getAttrs: dom => ({
            src: dom.getAttribute('src'),
            title: dom.getAttribute('title'),
            alt: dom.getAttribute('alt'),
          }),
        },
      ],
      toDOM: node => ['img', node.attrs],
    }
  }

  commands({ type }) {
    return attrs => (state, dispatch) => {
      const { selection } = state
      const position = selection.$cursor ? selection.$cursor.pos : selection.$to.pos
      const node = type.create(attrs)
      const transaction = state.tr.insert(position, node)
      dispatch(transaction)
    }
  }

  get plugins() {
    return [
      new Plugin({
        props: {
          handleDOMEvents: {
            drop(view, event) {
              // first -> upload the file and callback with progress and when it's done
              // display an uploading image, and when the upload is complete, replace the src with the url.
              console.log("we got this")
              const hasFiles = event.dataTransfer
              && event.dataTransfer.files
              && event.dataTransfer.files.length

              if (!hasFiles) {
                return
              }

              const images = Array
                .from(event.dataTransfer.files)
                .filter(file => (/image/i).test(file.type))

              if (images.length === 0) {
                return
              }

              event.preventDefault()

              const { schema } = view.state
              const coordinates = view.posAtCoords({ left: event.clientX, top: event.clientY })
              debugger
              // A fresh object to act as the ID for this upload
              let id = {}

              // Replace the selection with a placeholder
              let tr = view.state.tr
              if (!tr.selection.empty) tr.deleteSelection()
              tr.setMeta(placeholderPlugin, {add: {id, pos: tr.selection.from}})
              view.dispatch(tr)


              images.forEach(image => {


                const callbacks = {
                  progress: function(e) {
                    if (e.lengthComputable) {
                      console.log("uploading: ", parseInt(e.loaded / e.total * 100));
                    }
                  }
                }

                const uploader = new FileUploader(callbacks)

                uploader.upload(image).then(blob => {

                  let pos = findPlaceholder(view.state, id)
                  // If the content around the placeholder has been deleted, drop
                  // the image
                  if (pos == null) return
                  // Otherwise, insert it at the placeholder's position, and remove
                  // the placeholder
                  view.dispatch(view.state.tr
                    .replaceWith(pos, pos, schema.nodes.image.create({src: url}))
                    .setMeta(placeholderPlugin, {remove: {id}}))
                  const node = schema.nodes.image.create({
                    src: blob.preview_url,
                  })
                  const transaction = view.state.tr.insert(coordinates.pos, node)
                  view.dispatch(transaction)
                }, () => {
                  // On failure, just clean up the placeholder
                  view.dispatch(tr.setMeta(placeholderPlugin, {remove: {id}}))
                })
              })
            },
          },
        },
      }),
    ]
  }

}
