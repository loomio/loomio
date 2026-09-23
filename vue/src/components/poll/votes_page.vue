<script setup>
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import { ref } from 'vue';
import { useRoute } from 'vue-router';
import { useI18n } from 'vue-i18n';

const route = useRoute();
const { t } = useI18n();
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
  v-container(v-if="poll")
    v-sheet.votes-page.mb-8.pb-4.rounded-lg.pa-4(elevation=1)
      loading(:until="poll")
        topic-header(:topicable="poll" :subpage-title="t('poll_common.votes')" :subpage-parent-to="`/p/${poll.key}`")
        poll-common-votes-panel(:poll="poll")
</template>
