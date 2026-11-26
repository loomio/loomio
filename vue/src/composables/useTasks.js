import { ref } from 'vue';
import Records from '@/shared/services/records';

let tasksPromise = null;
const taskIds = ref([]);

export function useTasks() {
  function loadTasks() {
    if (!tasksPromise) {
      tasksPromise = Records.tasks.fetch({}).then(data => {
        taskIds.value = (data?.tasks || []).map(t => t.id);
        return data;
      }).catch(() => {
        tasksPromise = null;
      });
    }
    return tasksPromise;
  }

  return { loadTasks, taskIds };
}
