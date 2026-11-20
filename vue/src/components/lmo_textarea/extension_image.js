import Image from '@tiptap/extension-image'
import { Plugin, PluginKey } from '@tiptap/pm/state'
import {Decoration, DecorationSet} from '@tiptap/pm/view'
import {
  Node,
  nodeInputRule,
  mergeAttributes,
} from '@tiptap/core'

import { isDraftImagePreview } from './draft_image_preview'
import { DRAFT_IMAGE_BUDGET } from './draft_image_content'
import { clipboardUploadFiles } from '@/shared/helpers/clipboard_upload_files.mjs'

let count = 0;

export const inputRegex = /!\[(.+|:?)]\((\S+)(?:(?:\s+)["'](\S+)["'])?\)/

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

function handleUploads({files, view, attachFile, attachImageFile, coordinates}) {
  Array.from(files || []).forEach(file => {
    if ((/^(image|video|audio)\//i).test(file.type)) {
      insertImage(file, view, coordinates, attachImageFile)
    } else {
      attachFile({file})
    }
  })
}

export function insertImage(file, view, coordinates, attachImageFile) {
  const { schema } = view.state

  const id = "image"+(count++)
  // Replace the selection with a placeholder
  let tr = view.state.tr
  if (!tr.selection.empty) {
    tr.deleteSelection()
    tr.setMeta('uploadPlaceholder', {add: {id, pos: tr.selection.from}})
  } else if (coordinates) {
    tr.setMeta('uploadPlaceholder', {add: {id, pos: coordinates.pos}})
  } else {
    tr.setMeta('uploadPlaceholder', {add: {id, pos: tr.selection.from}})
  }
  view.dispatch(tr)

  attachImageFile({
    file: file,
    onProgress: (e) => {
      document.getElementById(id)?.setAttribute("value", parseInt(e.loaded / e.total * 100))
    },
    onComplete: (blob, draftImage) => {
      let node;
      if (file.type.startsWith('image/')) {
        const { preview, width, height } = draftImage || {};
        const scale = Math.min(1, 1280 / Math.max(width, height));
        node = schema.nodes.image.create({
          src: blob.preview_url || blob.download_url,
          draftPreview: preview ?? null,
          width: Math.round(width * scale) || null,
          height: Math.round(height * scale) || null,
        });
      } else if (file.type.startsWith('video/')) {
        node = schema.nodes.video.create({ src: blob.download_url, poster: blob.preview_url });
      } else if (file.type.startsWith('audio/')) {
        node = schema.nodes.audio.create({ src: blob.download_url });
      }

      if (view.isDestroyed) return;
      const pos = finduploadPlaceholder(view.state, id);
      if (pos == null) return;

      view.dispatch(view.state.tr
        .replaceWith(pos, pos, node)
        .setMeta('uploadPlaceholder', { remove: { id } }));
    },
    onFailure: () => {
      if (view.isDestroyed) return;
      view.dispatch(view.state.tr.setMeta('uploadPlaceholder', { remove: { id } }));
    }
  })
}

export const Video = Node.create({
  name: 'video',
  group: 'block',
  selectable: true,
  draggable: true,
  atom: true,
  parseHTML() {
    return [
      {
        tag: 'video',
      },
    ]
  },
  renderHTML({ HTMLAttributes }) {
      return ['video', mergeAttributes(HTMLAttributes)];
  },

  addAttributes() {
    return {
      "src": {
        default: null
      },
      "controls": {
        default: true
      },
      "poster": {
        default: null
      }
    }
  },
});

export const Audio = Node.create({
  name: 'audio',
  group: 'block',
  selectable: true,
  draggable: true,
  atom: true,
  parseHTML() {
    return [
      {
        tag: 'audio',
      },
    ]
  },
  
  renderHTML({ HTMLAttributes }) {
      return ['audio', mergeAttributes(HTMLAttributes)];
  },

  addAttributes() {
    return {
      "src": {
        default: null
      },
      "controls": {
        default: true
      }
    }
  },
});

export const CustomImage = Image.extend({
  addAttributes() {
    return {
      src: {
        default: null,
      },
      // Yjs syncs this field. HTML serialization and parsing use the stable src.
      draftPreview: {
        default: null,
        rendered: false,
        parseHTML: () => null,
      },
      alt: {
        default: null,
      },
      title: {
        default: null,
      },
      width: {
        default: null,
      },
      height: {
        default: null,
      },
    }
  },
  addInputRules() {
    return [
      nodeInputRule({
        find: inputRegex,
        type: this.type,
        getAttributes: match => {
          const [, alt, src, title, width, height] = match
          return { src, alt, title, width, height }
        }
      }),
    ]
  },
  addProseMirrorPlugins() {
    const canAttachFiles = this.options.canAttachFiles || (() => true)
    const attachFile = this.options.attachFile
    const attachImageFile = this.options.attachImageFile
    return [
      uploadPlaceholderPlugin,
      // Evaluate the merged document in document order, including previews
      // inserted concurrently by different collaborators.
      new Plugin({
        appendTransaction(transactions, _oldState, state) {
          if (!transactions.some(transaction => transaction.docChanged)) return null;

          let remaining = DRAFT_IMAGE_BUDGET;
          let trimmed;
          state.doc.descendants((node, position) => {
            const preview = node.attrs.draftPreview;
            if (!isDraftImagePreview(preview)) return;

            if (preview.length <= remaining) {
              remaining -= preview.length;
            } else {
              trimmed ||= state.tr;
              trimmed.setNodeAttribute(position, 'draftPreview', null);
            }
          });
          return trimmed;
        },
      }),
      new Plugin({
        props: {
          handleDOMEvents: {
            paste(view, event) {
              const files = clipboardUploadFiles(event.clipboardData)

              if (files.length === 0) {
                return
              }

              event.preventDefault()
              if (!canAttachFiles()) { return true }
              const coordinates = null;
              handleUploads({files, view, attachFile, attachImageFile, coordinates})
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

              if (!canAttachFiles()) { return true }
              const coordinates = view.posAtCoords({ left: event.clientX, top: event.clientY })

              handleUploads({files: event.dataTransfer.files, view, attachFile, attachImageFile, coordinates})
            },
          },
        },
      }),
    ]
  },
})
