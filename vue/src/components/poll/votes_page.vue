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
  v-container.max-width-800
    loading(:until="poll")
      .d-flex.align-center.mb-4
        v-breadcrumbs
          v-breadcrumbs-item(:to="'/p/' + poll.key")
            span {{ poll.title }}
          v-breadcrumbs-item
            span(v-t="'poll_common.votes'")
      poll-common-votes-panel(:poll="poll")
</template>
