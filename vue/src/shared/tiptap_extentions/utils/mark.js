/**
 * Utils: mark
 * @author Leecason
 * @license MIT, https://github.com/Leecason/element-tiptap/blob/master/LICENSE
 * @see https://github.com/Leecason/element-tiptap/blob/master/src/utils/apply_mark.ts
 */
import { getMarkAttrs } from 'tiptap-utils'
import { TextSelection } from 'prosemirror-state'

function markApplies (doc, ranges, type) {
  for (let i = 0; i < ranges.length; i++) {
    const { $from, $to } = ranges[i]
    let can = $from.depth === 0 ? doc.type.allowsMarkType(type) : false
    doc.nodesBetween($from.pos, $to.pos, node => {
      if (can) {
        return false
      }

      can = node.inlineContent && node.type.allowsMarkType(type)
      return true
    })
    if (can) {
      return true
    }
  }
  return false
}

// https://github.com/ProseMirror/prosemirror-commands/blob/master/src/commands.js
function applyMark (tr, markType, attrs) {
  if (!tr.selection || !tr.doc || !markType) {
    return tr
  }

  // @ts-ignore
  const { empty, $cursor, ranges } = tr.selection

  if ((empty && !$cursor) || !markApplies(tr.doc, ranges, markType)) {
    return tr
  }

  if ($cursor) {
    tr = tr.removeStoredMark(markType)
    return attrs ? tr.addStoredMark(markType.create(attrs)) : tr
  }

  let has = false
  for (let i = 0; !has && i < ranges.length; i++) {
    const { $from, $to } = ranges[i]
    has = tr.doc.rangeHasMark($from.pos, $to.pos, markType)
  }

  for (let i = 0; i < ranges.length; i++) {
    const { $from, $to } = ranges[i]
    if (has) {
      tr = tr.removeMark($from.pos, $to.pos, markType)
    }
    if (attrs) {
      tr = tr.addMark($from.pos, $to.pos, markType.create(attrs))
    }
  }

  return tr
}

function findActiveFontFamily (state) {
  const { schema, selection, tr } = state
  const markType = schema.marks.fontFamily

  if (!markType) {
    return ''
  }

  const { empty } = selection

  if (empty) {
    const storedMarks = tr.storedMarks ||
      state.storedMarks ||
      (
        selection instanceof TextSelection &&
        selection.$cursor &&
        selection.$cursor.marks &&
        selection.$cursor.marks()
      ) ||
      []

    const sm = storedMarks.find((m) => m.type === markType)
    return (sm && sm.attrs.fontFamily) || ''
  }

  const attrs = getMarkAttrs(state, markType)
  const fontFamily = attrs.fontFamily

  if (!fontFamily) {
    return ''
  }

  return fontFamily
}

function findActiveMarkAttribute (state, name) {
  const { schema, selection, tr } = state
  const markType = schema.marks[name]

  if (!markType) {
    return ''
  }

  const { empty } = selection

  if (empty) {
    const storedMarks = tr.storedMarks ||
      state.storedMarks ||
      (
        selection instanceof TextSelection &&
        selection.$cursor &&
        selection.$cursor.marks &&
        selection.$cursor.marks()
      ) ||
      []

    const sm = storedMarks.find((m) => m.type === markType)
    return (sm && sm.attrs[name]) || ''
  }

  const attrs = getMarkAttrs(state, markType)
  const value = attrs[name]

  if (!value) {
    return ''
  }

  return value
}

export { applyMark, findActiveFontFamily, findActiveMarkAttribute }
