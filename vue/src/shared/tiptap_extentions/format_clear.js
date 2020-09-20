/**
 * Extension: format clear
 *
 * @author Leecason
 * @license MIT, https://github.com/Leecason/element-tiptap/blob/master/LICENSE
 * @see https://github.com/Leecason/element-tiptap/blob/master/src/extensions/format_clear.ts
 */
import { Extension } from 'tiptap'
import { clearMarks } from './utils/format_clear'

export default class FormatClear extends Extension {
  get name () {
    return 'formatClear'
  }

  commands ({ type }) {
    return () => (state, dispatch) => {
      const tr = clearMarks(state.tr.setSelection(state.selection), state.schema, type)

      if (dispatch && tr.docChanged) {
        dispatch(tr)
        return true
      }
      return false
    }
  }
}
