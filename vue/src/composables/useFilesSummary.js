import { reactive } from 'vue';
import Records from '@/shared/services/records';

const countsByKey = reactive({});
const inflightByKey = new Map();

export function useFilesSummary() {
  function keyFor(groupId) {
    return groupId ? String(groupId) : 'dashboard';
  }

  function setFilesCount(groupId, count) {
    if (typeof count === 'number') {
      countsByKey[keyFor(groupId)] = count;
    }
  }

  function getFilesCount(groupId) {
    const val = countsByKey[keyFor(groupId)];
    return typeof val === 'number' ? val : null;
  }

  function loadFilesSummary(groupId = null) {
    const key = keyFor(groupId);
    if (typeof countsByKey[key] === 'number' || !Records.remote?.get) {
      return Promise.resolve(countsByKey[key]);
    }
    if (!inflightByKey.has(key)) {
      const params = { limit: 1 };
      if (groupId) { params.group_id = groupId; }
      const promise = Records.remote.get('attachments', params).then(data => {
        const total = data?.meta?.total;
        setFilesCount(groupId, typeof total === 'number' ? total : 0);
        return countsByKey[key];
      }).catch(() => {
        inflightByKey.delete(key);
      });
      inflightByKey.set(key, promise);
    }
    return inflightByKey.get(key);
  }

  return { loadFilesSummary, getFilesCount, setFilesCount };
}
