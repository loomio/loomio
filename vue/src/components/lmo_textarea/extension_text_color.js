import { Command, Extension } from '@tiptap/core'

// type FontFamilyOptions = {
//   types: string[],
// }

// declare module '@tiptap/core' {
//   interface Commands {
//     fontFamily: {
//       /**
//        * Set the font family
//        */
//       setFontFamily: (fontFamily: string) => Command,
//       /**
//        * Unset the font family
//        */
//       unsetFontFamily: () => Command,
//     }
//   }
// }

export const TextColor = Extension.create({
  name: 'textColor',

  defaultOptions: {
    types: ['textStyle'],
  },

  addGlobalAttributes() {
    return [
      {
        types: this.options.types,
        attributes: {
          textColor: {
            default: null,
            renderHTML: attributes => {
              if (!attributes.textColor) {
                return {}
              }

              return {
                style: `color: ${attributes.textColor}`,
              }
            },
            parseHTML: element => ({
              textColor: element.style.color
            }),
          },
        },
      },
    ]
  },

  addCommands() {
    return {
      setTextColor: textColor => ({ chain }) => {
        return chain()
          .setMark('textStyle', { textColor })
          .run()
      },
      unsetTextColor: () => ({ chain }) => {
        return chain()
          .setMark('textStyle', { textColor: null })
          .removeEmptyTextStyle()
          .run()
      },
    }
  },
})
