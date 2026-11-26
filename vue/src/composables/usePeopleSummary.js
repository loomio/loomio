import { ref } from 'vue';
import Records from '@/shared/services/records';

let summaryPromise = null;
const recentlyOnlineCount = ref(null);

export function usePeopleSummary() {
  function setRecentlyOnlineCount(count) {
    if (typeof count === 'number') {
      recentlyOnlineCount.value = count;
    }
  }

  function loadPeopleSummary() {
    if (!summaryPromise) {
      summaryPromise = Records.remote.get('memberships/people', { per: 1 }).then(data => {
        setRecentlyOnlineCount(data?.recently_online_count);
        return data;
      }).catch(() => {
        summaryPromise = null;
      });
    }
    return summaryPromise;
  }

  return { loadPeopleSummary, recentlyOnlineCount, setRecentlyOnlineCount };
}
