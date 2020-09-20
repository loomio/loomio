import { markInputRule } from 'tiptap-commands'
import { Mark } from 'tiptap'
import { applyMark } from './utils/mark'

export default class Align extends Mark {
  get name () {
    return 'align'
  }

  get schema () {
    return {
      attrs: {
        textAlign: {
          default: 'left'
        }
      },
      parseDOM: [
        {
          style: 'text-align',
          getAttrs: value => ({ textAlign: value })
        }
      ],
      toDOM: mark => ['span', { style: `text-align: ${mark.attrs.textAlign}; display: block` }, 0]
    }
  }

  commands ({ type }) {
    return attrs => (state, dispatch) => {
      let { tr } = state
      tr = applyMark(state.tr.setSelection(state.selection), type, attrs)
      if (tr.docChanged || tr.storedMarksSet) {
        dispatch && dispatch(tr)
        return true
      }
    }
  }

  inputRules ({ type }) {
    return [
      markInputRule(/(?:\*\*|__)([^*_]+)(?:\*\*|__)$/, type)
    ]
  }
}
