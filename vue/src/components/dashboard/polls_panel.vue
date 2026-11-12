<script setup lang="js">
import { computed } from 'vue';
import { usePendingPolls } from '@/composables/usePendingPolls';

const { loadPendingPolls, findPendingPolls } = usePendingPolls();
const votePolls = computed(() => findPendingPolls());

loadPendingPolls();
</script>

<template lang="pug">
.polls-panel(v-if='votePolls.length')
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
</template>
