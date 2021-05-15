import TaskItem from '@tiptap/extension-task-item'
import Session from '@/shared/services/session'

export const CustomTaskItem = TaskItem.extend({
  addAttributes() {
    return {
      uid: {
        default: Math.floor(Math.random() * 90000000),
        parseHTML: element => ({
          uid: parseInt(element.getAttribute('data-uid'))
        }),
        renderHTML: attributes => ({
          'data-uid': attributes.uid,
        }),
        keepOnSplit: false,
      },

      checked: {
        default: false,
        // Take the attribute values
        parseHTML: element => ({
          checked: element.getAttribute('data-checked') === 'true'
        }),
        renderHTML: attributes => ({
          'data-checked': attributes.checked,
        }),
        keepOnSplit: false,
      },

      authorId: {
        default: Session.user().id,
        parseHTML: element => ({
          authorId: parseInt(element.getAttribute('data-author-id'))
        }),
        renderHTML: attributes => ({
          'data-author-id': attributes.authorId,
        }),
        keepOnSplit: false,
      }
    }
  },
  parseHTML() {
    return [
      {
        tag: 'li[data-type="taskItem"]',
        priority: 51,
      },
      {
        tag: 'li[data-type="todo_item"]',
        priority: 51,
      },
    ]
  },

  addNodeView() {
    return ({
      node,
      HTMLAttributes,
      getPos,
      editor,
    }) => {
      const listItem = document.createElement('li')
      const checkboxWrapper = document.createElement('label')
      const checkboxStyler = document.createElement('span')
      const checkbox = document.createElement('input')
      const content = document.createElement('div')

      checkboxWrapper.contentEditable = 'false'
      checkbox.type = 'checkbox'
      checkbox.addEventListener('change', event => {
        const { checked } = event.target

        if (typeof getPos === 'function') {
          editor
            .chain()
            .focus()
            .command(({ tr }) => {
              console.log('tr', tr)
              console.log('node.attrs', node.attrs)
              console.log('node.innerHtml', node)
              tr.setNodeMarkup(getPos(), undefined, {
                checked: checked,
                uid: node.attrs.uid,
                authorId: node.attrs.authorId,
              })

              return true
            })
            .run()
        }
      })


      if (node.attrs.checked) {
        checkbox.setAttribute('checked', 'checked')
      }

      checkboxWrapper.append(checkbox, checkboxStyler)
      listItem.append(checkboxWrapper, content)


      Object
        .entries(HTMLAttributes)
        .forEach(([key, value]) => {
          listItem.setAttribute(key, value)
        })
      console.log("hmltattributes", HTMLAttributes)
      console.log('listitem.get data-uid', listItem.getAttribute('data-uid'))

      return {
        dom: listItem,
        contentDOM: content,
        update: updatedNode => {
          if (updatedNode.type !== this.type) {
            return false
          }

          if (updatedNode.attrs.checked) {
            checkbox.setAttribute('checked', 'checked')
          } else {
            checkbox.removeAttribute('checked')
          }

          return true
        },
      }
    }
  },
})
