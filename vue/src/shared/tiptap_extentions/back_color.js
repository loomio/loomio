import { markInputRule } from 'tiptap-commands'
import { Mark } from 'tiptap'
import { applyMark } from '@/shared/tiptap_extentions/utils/mark'

export default class BackColor extends Mark {
  get name () {
    return 'backColor'
  }

  get schema () {
    return {
      attrs: {
        backColor: {
          default: '#000000'
        }
      },
      parseDOM: [
        {
          style: 'background',
          getAttrs: value => ({ backColor: value })
        }
      ],
      toDOM: mark => ['span', { style: `background: ${mark.attrs.backColor}` }, 0]
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
