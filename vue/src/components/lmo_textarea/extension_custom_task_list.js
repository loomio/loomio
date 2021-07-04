import TaskList from '@tiptap/extension-task-list'


export const CustomTaskList = TaskList.extend({
  parseHTML() {
    return [
      {
        tag: 'ul[data-type="taskList"]',
        priority: 51,
      },
      {
        tag: 'ul[data-type="task_list"]',
        priority: 51,
      },
    ]
  },
})
