import { ref, onUnmounted } from 'vue';
import Records from '@/shared/services/records';

export function useWatchRecords() {
  const watchedRecords = ref([]);

  const watchRecords = (options) => {
    const {
      collections,
      query,
      key
    } = options;
    
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
    watchRecords
  };
}