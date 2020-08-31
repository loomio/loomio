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
    lineHeight,
  } = dom.style

  const align = dom.getAttribute('data-text-align') || textAlign || ''
  const indent = parseInt(dom.getAttribute('data-indent'), 10) || 0

  return {
    textAlign: align,
    indent,
    lineHeight,
  }
}

function toDOM (node) {
  const {
    textAlign,
    indent,
    lineHeight,
  } = node.attrs

  const attrs = {}

  if (textAlign && textAlign !== 'left') {
    attrs['data-text-align'] = textAlign
  }

  if (indent) {
    attrs['data-indent'] = indent
  }

  if (lineHeight) {
    attrs['data-line-height'] = lineHeight
  }

  return ['p', attrs, 0]
}

export const ParagraphNodeSpec = {
  attrs: {
    textAlign: { default: null },
    indent: { default: null },
    lineHeight: { default: null },
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
