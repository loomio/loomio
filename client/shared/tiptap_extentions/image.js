import { Node, Plugin, PluginKey} from 'tiptap'
import {Decoration, DecorationSet} from 'prosemirror-view'

import FileUploader from 'shared/services/file_uploader'

const placeholderPlugin = new Plugin({
   state: {
    key: new PluginKey('placeholder'),
    init() { return DecorationSet.empty },
    apply(tr, set)  {
      // Adjust decoration positions to changes made by the transaction
      set = set.map(tr.mapping, tr.doc)
      // See if the transaction adds or removes any placeholders
      let action = tr.getMeta('placeholder')
      if (action && action.add) {
        let widget = document.createElement("placeholder")
        let deco = Decoration.widget(action.add.pos, widget, {id: action.add.id})
        set = set.add(tr.doc, [deco])
      } else if (action && action.remove) {
        set = set.remove(set.find(null, null,
                                  spec => spec.id == action.remove.id))
      }
      return set
    }
  },
  props: {
    decorations(state) { return this.getState(state) }
  }
})

function findPlaceholder(state, id) {
  let decos = placeholderPlugin.getState(state)
  let found = decos.find(null, null, spec => spec.id == id)
  return found.length ? found[0].from : null
}

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
      placeholderPlugin,
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

              images.forEach(image => {
                // A fresh object to act as the ID for this upload
                let id = {}

                // Replace the selection with a placeholder
                let tr = view.state.tr
                if (!tr.selection.empty) tr.deleteSelection()
                tr.setMeta('placeholder', {add: {id, pos: tr.selection.from}})
                view.dispatch(tr)


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
                    .replaceWith(pos, pos, schema.nodes.image.create({src: blob.preview_url}))
                    .setMeta('placeholder', {remove: {id}}))
                  // const node = schema.nodes.image.create({
                  //   src: blob.preview_url,
                  // })
                  // const transaction = view.state.tr.insert(coordinates.pos, node)
                  // view.dispatch(transaction)
                }, () => {
                  // On failure, just clean up the placeholder
                  view.dispatch(tr.setMeta('placeholder', {remove: {id}}))
                })
              })
            },
          },
        },
      }),
    ]
  }

}
