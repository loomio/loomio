import { mergeAttributes, Node, nodeInputRule } from "@tiptap/core"

export const inputRegex = /(?:^|\s)(!\[(.+|:?)]\((\S+)(?:(?:\s+)["'](\S+)["'])?\))$/

export const Video = Node.create({
  name: "video",

  addOptions() {
    return {
      HTMLAttributes: {}
    }
  },

  inline() {
    return false
  },

  group() {
    return "block"
  },

  draggable: true,

  addAttributes() {
    return {
      src: {
        default: null
      },
      alt: {
        default: null
      },
      title: {
        default: null
      }
    }
  },

  parseHTML() {
    return [
      {
        tag: "img[src]"
      }
    ]
  },

  renderHTML({ HTMLAttributes }) {
    return ["img", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes)]
  },

  addCommands() {
    return {
      setVideo: options => ({ commands }) => {
        return commands.insertContent({
          type: this.name,
          attrs: options
        })
      }
    }
  },

  addInputRules() {
    return [
      nodeInputRule({
        find: inputRegex,
        type: this.type,
        getAttributes: match => {
          const [, , alt, src, title] = match

          return { src, alt, title }
        }
      })
    ]
  }
})
