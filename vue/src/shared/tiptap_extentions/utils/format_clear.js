/**
 * Utils: clear formats
 * @author Leecason
 * @license MIT, https://github.com/Leecason/element-tiptap/blob/master/LICENSE
 * @see https://github.com/Leecason/element-tiptap/blob/master/src/utils/format_clear.ts
 */
import { setAlignment } from './alignment'

const FORMAT_MARK_NAMES = [
  'align',
  'bold',
  'italic',
  'underline',
  'strike',
  'link',
  'foreColor',
  'backColor',
  'fontFamily',
  'indent',
]

export function clearMarks (tr, schema, type) {
  const { doc, selection } = tr
  if (!selection || !doc) {
    return tr
  }

  const { from, to, empty } = selection
  if (empty) {
    return tr
  }

  const markTypesToRemove = new Set(
    FORMAT_MARK_NAMES.map(n => schema.marks[n]).filter(Boolean)
  )

  if (!markTypesToRemove.size) {
    return tr
  }

  const tasks = []
  doc.nodesBetween(from, to, (node, pos) => {
    if (node.marks && node.marks.length) {
      node.marks.some(mark => {
        if (markTypesToRemove.has(mark.type)) {
          tasks.push({ node, pos, mark })
        }
      })
      return true
    }
    return true
  })

  tasks.forEach(job => {
    const { node, mark, pos } = job
    tr = tr.removeMark(pos, pos + node.nodeSize, mark.type)
  })

  // setAlignment(type, { textAlign: 'right' })
  // tr = setLineHeight(tr, null)
  // tr = cleanIndent(tr)

  return tr
}
