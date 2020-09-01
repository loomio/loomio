import { Node } from 'tiptap'
import { setBlockType, textblockTypeInputRule, toggleBlockType } from 'tiptap-commands'
import { ParagraphNodeSpec, getParagraphNodeAttrs, toParagraphDOM } from '@/shared/tiptap_extentions/paragraph'

function getUuid () {
  const s = []
  const hexDigits = '0123456789abcdef'
  for (let i = 0; i < 36; i++) {
    s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1)
  }
  s[14] = '4' // bits 12-15 of the time_hi_and_version field to 0010
  s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1) // bits 6-7 of the clock_seq_hi_and_reserved to 01
  s[8] = s[13] = s[18] = s[23] = '' // -

  return s.join('').substr(0, 6)
}

function getAttrs (dom) {
  const attrs = getParagraphNodeAttrs(dom)
  const id = dom.getAttribute('id')
  // const level = parseInt(dom.getAttribute('level'), 10) || 0
  attrs.id = id
  // attrs.level = level
  return attrs
}

function toDOM (node) {
  const dom = toParagraphDOM(node)
  const id = node.attrs.id || getUuid()
  const level = node.attrs.level || 1
  dom[0] = 'h'.concat(node.attrs.level)
  dom[1].id = id
  // dom[1].level = level

  node.attrs.id = id

  return dom
}

export default class Heading extends Node {
  get name () {
    return 'heading'
  }

  get defaultOptions () {
    return {
      levels: [1, 2, 3, 4, 5, 6],
    }
  }

  get schema () {
    return {
      ...ParagraphNodeSpec,
      attrs: {
        ...ParagraphNodeSpec.attrs,
        level: {
          default: 1,
        },
        id: {
          default: ''
        }
      },
      content: 'inline*',
      group: 'block',
      defining: true,
      draggable: false,
      parseDOM: this.options.levels
        .map(level => ({
          tag: `h${level}`,
          getAttrs
        })),
      toDOM
    }
  }

  commands ({ type, schema }) {
    return attrs => toggleBlockType(type, schema.nodes.paragraph, attrs)
  }

  keys ({ type }) {
    return this.options.levels.reduce((items, level) => ({
      ...items,
      ...{
        [`Shift-Ctrl-${level}`]: setBlockType(type, { level }),
      },
    }), {})
  }

  inputRules ({ type }) {
    return this.options.levels.map(level => textblockTypeInputRule(
      new RegExp(`^(#{1,${level}})\\s$`),
      type,
      () => ({ level }),
    ))
  }
}
