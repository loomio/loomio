/**
 * Extension: paragraph
 *
 * @author Leecason
 * @license MIT, https://github.com/Leecason/element-tiptap/blob/master/LICENSE
 * @see https://github.com/Leecason/element-tiptap/blob/master/src/extensions/paragraph.ts
 */
import { Paragraph as TiptapParagraph } from 'tiptap'

function getAttrs (dom) {
  let {
    textAlign,
  } = dom.style

  const align = dom.getAttribute('data-text-align') || textAlign || ''

  return {
    textAlign: align
  }
}

function toDOM (node) {
  const { textAlign } = node.attrs

  const attrs = {}

  if (textAlign && textAlign !== 'left') {
    attrs['data-text-align'] = textAlign
  }

  return ['p', attrs, 0]
}

export const ParagraphNodeSpec = {
  attrs: {
    textAlign: { default: null },
  },
  content: 'inline*',
  group: 'block',
  parseDOM: [{
    tag: 'p',
    getAttrs,
  }],
  toDOM,
}

export default class Paragraph extends TiptapParagraph {
  get schema () {
    return ParagraphNodeSpec
  }
}

export const toParagraphDOM = toDOM
export const getParagraphNodeAttrs = getAttrs
