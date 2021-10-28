import {
  Mark,
  markInputRule,
  markPasteRule,
  mergeAttributes,
} from '@tiptap/core'

export const inputRegex = /(?:^|\s)((?:==)((?:[^~]+))(?:==))$/
export const pasteRegex = /(?:^|\s)((?:==)((?:[^~]+))(?:==))/g

export const Highlight = Mark.create({
  name: 'highlight',

  addOptions: {
    HTMLAttributes: {},
  },

  addAttributes() {
    return {
      color: {
        default: null,
        parseHTML: element => ( element.getAttribute('data-color') ),
        renderHTML: attributes => {
          if (!attributes.color) { return {} }

          return { 'data-color': attributes.color }
        },
      },
    }
  },

  parseHTML() {
    return [
      {
        tag: 'mark',
      },
    ]
  },

  renderHTML({ HTMLAttributes }) {
    return ['mark', mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0]
  },

  addCommands() {
    return {
      setHighlight: attributes => ({ commands }) => {
        return commands.setMark('highlight', attributes)
      },
      toggleHighlight: attributes => ({ commands }) => {
        return commands.toggleMark('highlight', attributes)
      },
      unsetHighlight: () => ({ commands }) => {
        return commands.unsetMark('highlight')
      },
    }
  },

  addKeyboardShortcuts() {
    return {
      'Mod-Shift-h': () => this.editor.commands.toggleHighlight(),
    }
  },

  addInputRules() {
    return [
      markInputRule({
        find: inputRegex,
        type: this.type,
      }),
    ]
  },

  addPasteRules() {
    return [
      markPasteRule({
        find: pasteRegex,
        type: this.type,
      }),
    ]
  },
})
