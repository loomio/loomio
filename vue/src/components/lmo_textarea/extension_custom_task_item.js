import TaskItem from '@tiptap/extension-task-item'
import Session from '@/shared/services/session'
import { VueNodeViewRenderer } from '@tiptap/vue-2'
import TaskItemComponent from './task_item_component.vue'

export const CustomTaskItem = TaskItem.extend({
  draggable: true,
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

      dueOn: {
        default: null,
        parseHTML: element => ({
          dueOn: element.getAttribute('data-due-on')
        }),
        renderHTML: attributes => ({
          'data-due-on': attributes.dueOn,
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
    return VueNodeViewRenderer(TaskItemComponent)
  },
})
