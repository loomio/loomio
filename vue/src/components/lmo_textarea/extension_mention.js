import Mention from '@tiptap/extension-mention'
import { Node, mergeAttributes } from '@tiptap/core'
import Suggestion, { SuggestionOptions } from '@tiptap/suggestion'
// getLabel(dom) {
//   return dom.innerText.split(this.options.matcher.char).join('')
// }
export const CustomMention = Mention.extend({
  addAttributes() {
    return {
      id: {
        default: null,
        parseHTML: element => {
          return {
            id: element.getAttribute('data-mention-id'),
            label: element.innerText.split('@').join('')
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

  parseHTML() {
    return [
      {
        tag: 'span[data-mention-id]',
      },
    ]
  },
})
