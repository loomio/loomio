import { ref, onUnmounted } from 'vue';
import Records from '@/shared/services/records';

export function useWatchRecords() {
  const watchedRecords = ref([]);

  const watchRecords = (...args) => {
    const obj = args[0];
    const { collections, query, key } = obj;
    const name = collections.concat(key || parseInt(Math.random() * 10000)).join('_');
    watchedRecords.value.push(name);
    Records.view({
      name,
      collections,
      query
    });
  };

  onUnmounted(() => {
    watchedRecords.value.forEach(name => delete Records.views[name]);
  });

  return {
    watchRecords,
    watchedRecords
  };
}
