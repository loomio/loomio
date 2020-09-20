import { markInputRule } from 'tiptap-commands'
import { Mark } from 'tiptap'
import { applyMark } from '@/shared/tiptap_extentions/utils/mark'

export default class ForeColor extends Mark {
  get name () {
    return 'foreColor'
  }

  get schema () {
    return {
      attrs: {
        foreColor: {
          default: '#000000'
        }
      },
      parseDOM: [
        {
          style: 'color',
          getAttrs: value => ({ foreColor: value })
        }
      ],
      toDOM: mark => ['span', { style: `color: ${mark.attrs.foreColor}` }, 0]
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
