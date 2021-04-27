import Mention from '@tiptap/extension-mention'
import { Node, mergeAttributes } from '@tiptap/core'
import Suggestion, { SuggestionOptions } from '@tiptap/suggestion'
// getLabel(dom) {
//   return dom.innerText.split(this.options.matcher.char).join('')
// }
export const CustomMention = Mention.extend({
  defaultOptions: {
    HTMLAttributes: {},
    suggestion: {
      char: '@',
      command: ({ editor, range, props }) => {
        console.log(editor, range, props)
        editor
          .chain()
          .focus()
          .replaceRange(range, 'mention', props)
          .insertContent(' ')
          .run()
      },
      allow: ({ editor, range }) => {
        return editor.can().replaceRange(range, 'mention')
      },
    },
  },

  addAttributes() {
    return {
      id: {
        default: null,
        parseHTML: element => {
          return {
            id: element.getAttribute('data-mention-id'),
            label: element.innerText.split(this.options.matcher.char).join('')
          }
        },
        renderHTML: attributes => {
          if (!attributes.id) {
            return {}
          }

          return {
            'data-mention-id': attributes.id,
          }
        },
      },
      label: {
        default: null,
        parseHTML: element => {
          return {
            label: element.getAttribute('data-label'),
          }
        },
      },
    }
  },
  renderHTML({ node, HTMLAttributes }) {
    return ['span', mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), `@${node.attrs.label}`]
  },
})
