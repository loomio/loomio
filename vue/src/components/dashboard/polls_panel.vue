<script setup lang="js">
import { ref } from 'vue';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { usePendingPolls } from '@/composables/usePendingPolls';

const { watchRecords } = useWatchRecords();
const { loadPendingPolls, findPendingPolls, loading } = usePendingPolls();
const votePolls = ref([]);

watchRecords({
  collections: ['polls', 'memberships', 'stances'],
  query: () => { votePolls.value = findPendingPolls(); }
});

loadPendingPolls();
</script>

<template lang="pug">
.polls-panel(v-if='votePolls.length || loading')
  v-card.mb-2(variant="flat")
    v-list(lines="two")
      template(v-if="votePolls.length")
        v-list-subheader(v-t="'dashboard_page.polls_to_vote_on'")
        poll-common-preview(
          display-group-name
          full-name
          :poll="poll",
          v-for="poll in votePolls",
          :key="poll.id"
        )
      template(v-if='!votePolls.length && loading')
        v-list-subheader(v-t="'group_page.polls'")
        loading-content(:lineCount='2' v-for='(item, index) in [1]' :key='index' )
</template>
