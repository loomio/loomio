import { Node, Plugin, PluginKey} from 'tiptap'
import {Decoration, DecorationSet} from 'prosemirror-view'

import FileUploader from 'shared/services/file_uploader'

let count = 0;

const uploadPlaceholderPlugin = new Plugin({
   state: {
    key: new PluginKey('uploadPlaceholder'),
    init() { return DecorationSet.empty },
    apply(tr, set)  {
      // Adjust decoration positions to changes made by the transaction
      set = set.map(tr.mapping, tr.doc)
      // See if the transaction adds or removes any placeholders
      let action = tr.getMeta('uploadPlaceholder')
      if (action && action.add) {
        let widget = document.createElement("progress")
        widget.setAttribute("id", action.add.id)
        widget.setAttribute("max", 100)
        widget.setAttribute("value", 0)
        let deco = Decoration.widget(action.add.pos, widget, {id: action.add.id})
        set = set.add(tr.doc, [deco])
      } else if (action && action.remove) {
        set = set.remove(set.find(null, null, spec => spec.id == action.remove.id))
      }
      return set
    }
  },
  props: {
    decorations(state) { return this.getState(state) }
  }
})

function finduploadPlaceholder(state, id) {
  let decos = uploadPlaceholderPlugin.getState(state)
  let found = decos.find(null, null, spec => spec.id == id)
  return found.length ? found[0].from : null
}

function insertImage(image, view) {
  const { schema } = view.state
  // A fresh object to act as the ID for this upload
  let id = "image"+(count++)

  // Replace the selection with a placeholder
  let tr = view.state.tr
  if (!tr.selection.empty) tr.deleteSelection()
  tr.setMeta('uploadPlaceholder', {add: {id, pos: tr.selection.from}})
  view.dispatch(tr)

  const callbacks = {
    progress: function(e) {
      if (e.lengthComputable) {
        document.getElementById(id).setAttribute("value", parseInt(e.loaded / e.total * 100))
      }
    }
  }

  const uploader = new FileUploader(callbacks)

  uploader.upload(image).then(blob => {
    let pos = finduploadPlaceholder(view.state, id)
    // If the content around the placeholder has been deleted, drop
    // the image
    if (pos == null) return
    // Otherwise, insert it at the placeholder's position, and remove
    // the placeholder
    view.dispatch(view.state.tr
      .replaceWith(pos, pos, schema.nodes.image.create({src: blob.preview_url}))
      .setMeta('uploadPlaceholder', {remove: {id}}))
  }, () => {
    // On failure, just clean up the placeholder
    view.dispatch(tr.setMeta('uploadPlaceholder', {remove: {id}}))
  })
}

function handleAttachments(attachments, view, attachFile) {
  Array.from(attachments).forEach(attachment => {
    if ((/image/i).test(attachment.type)) {
      insertImage(attachment, view)
    } else {
      attachFile(attachment)
    }
  })
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
    const attachFile = this.options.attachFile
    return [
      uploadPlaceholderPlugin,
      new Plugin({
        props: {
          handleDOMEvents: {
            paste(view, event) {
              const items = Array.from(event.clipboardData.items)

              if (items.filter(item => item.getAsFile()).length == 0) {
                return
              }

              event.preventDefault()
              const attachments = items.map(item =>
                new File([item.getAsFile()],
                         event.clipboardData.getData('text/plain') || Date.now(),
                         {lastModified: Date.now(), type: item.type})
              )
              handleAttachments(attachments, view, attachFile)
            },
            drop(view, event) {
              // first -> upload the file and callback with progress and when it's done
              // display an uploading image, and when the upload is complete, replace the src with the url.
              const hasFiles = event.dataTransfer
              && event.dataTransfer.files
              && event.dataTransfer.files.length

              if (!hasFiles) {
                return
              }
              event.preventDefault()

              handleAttachments(event.dataTransfer.files, view, attachFile)
            },
          },
        },
      }),
    ]
  }

}
