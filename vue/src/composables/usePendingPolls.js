import { ref } from 'vue';
import Records from '@/shared/services/records';

let pendingPollsPromise = null;
const loading = ref(false);

// Load every page once for all navigation counts and pending-vote lists.
// Poll responses include the viewer's stance or anonymous eligibility state.
async function fetchPendingPolls() {
  loading.value = true;
  try {
    let offset = 0;
    let total;
    do {
      const data = await Records.polls.fetch({params: {
        status: 'vote', limit: 100, offset
      }});
      if (data.polls.length === 0) break;
      offset += data.polls.length;
      total = data.meta.total;
    } while (offset < total);
  } finally {
    loading.value = false;
  }
}

export function usePendingPolls() {
  function loadPendingPolls() {
    pendingPollsPromise ||= fetchPendingPolls();
    return pendingPollsPromise;
  }

  function findPendingPolls() {
    return Records.polls.collection.chain()
      .find({discardedAt: null, closedAt: null, closingAt: {$gt: new Date()}})
      .simplesort('closingAt', true)
      .data()
      .filter(poll => poll.iCanVote() && !poll.iHaveVoted());
  }

  return { loadPendingPolls, findPendingPolls, loading };
}
