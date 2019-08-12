import { Link } from 'tiptap-extensions'
export default class CustomLink extends Link {
  get schema() {
    return {
      attrs: {
        href: {
            default: null,
        }
      },
      inclusive: false,
      parseDOM: [
        {
          tag: 'a[href]',
          getAttrs: dom => ({
            href: dom.getAttribute('href'),
          }),
        },
      ],
      toDOM: node => ['a', {
        ...node.attrs,
        target: '_blank',
      }, 0],
    }
  }
}
