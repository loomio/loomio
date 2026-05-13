<script setup>
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import { ref } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();
const poll = ref(null);

Records.polls.findOrFetchById(route.params.key).then(p => {
  poll.value = p;
  EventBus.$emit('currentComponent', {
    group: p.group(),
    poll: p,
    title: p.title,
    page: 'pollVotesPage'
  });
}).catch(error => {
  EventBus.$emit('pageError', error);
  if (error.status === 403 && !Session.isSignedIn()) { EventBus.$emit('openAuthModal'); }
});
</script>

<template lang="pug">
v-main
  v-container.max-width-800(v-if="poll")
    v-sheet.votes-page.mb-8.pb-4.rounded.pa-4(elevation=1)
      loading(:until="poll")
        strand-header(:topicable="poll")
        .d-flex.align-start
          user-avatar.mr-2.mt-1(:user="poll.author()" :size="32")
          poll-common-details-meta(:poll="poll")
        poll-common-outcome-panel(:outcome="poll.outcome()" v-if="poll.outcome()")
        formatted-text.poll-common-details-panel__details(v-if="poll.details" :model="poll" field="details")
        link-previews(v-if="poll.details" :model="poll")
        attachment-list(:attachments="poll.attachments")
        poll-common-chart-panel(:poll="poll" hide-view-all-votes hide-voters)
        poll-common-votes-panel(:poll="poll")
</template>
