import {
  Node,
  nodeInputRule,
  mergeAttributes,
} from '@tiptap/core'

export const inputRegex = /!\[(.+|:?)]\((\S+)(?:(?:\s+)["'](\S+)["'])?\)/

export const Iframe = Node.create({
  name: 'iframe',
  group: 'block',
  selectable: false,

  defaultOptions: {
    HTMLAttributes: {},
  },

  addAttributes() {
    return {
      src: {
        default: null,
      },
    }
  },

  // addNodeView() {
  //   return ({node}) => {
  //     console.log(node)
  //     const container = document.createElement('div')
  //     container.className = 'iframe-container'
  //     container.contentEditable = false
  //
  //     const content = document.createElement('iframe')
  //     content.setAttribute('src', node.attrs.src)
  //     container.append(content)
  //
  //     return {
  //       dom: container,
  //       contentDOM: node,
  //     }
  //   }
  // },

  parseHTML() {
    return [
      { tag: 'iframe[src]' },
    ]
  },

  renderHTML({ HTMLAttributes }) {
    return ['div', {class: 'iframe-container', allowfullscreen: true}, ['iframe', mergeAttributes(this.options.HTMLAttributes, HTMLAttributes)]]
  },

  renderText({ node }) {
    return node.attrs.src
  },

  addCommands() {
    return {
      setIframe: options => ({ tr, dispatch }) => {
        const { selection } = tr
        const node = this.type.create(options)

        if (dispatch) {
          tr.replaceRangeWith(selection.from, selection.to, node)
        }

        return true
      },
    }
  },

  addInputRules() {
    return [
      nodeInputRule(inputRegex, this.type, match => {
        const [, src] = match
        return { src }
      }),
    ]
  },
});
