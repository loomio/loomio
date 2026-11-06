<script setup lang="js">
import { ref, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import { escapeRegExp } from 'lodash-es';

import EventBus from '@/shared/services/event_bus';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { usePendingPolls } from '@/composables/usePendingPolls';

const route = useRoute();
const { watchRecords } = useWatchRecords();
const { loadPendingPolls, findPendingPolls, loading } = usePendingPolls();
const votePolls = ref([]);

function findRecords() {
  const polls = findPendingPolls();
  if (route.query.q) {
    const rx = new RegExp(escapeRegExp(route.query.q), 'i');
    votePolls.value = polls.filter(poll => rx.test(poll.title) || rx.test(poll.description));
  } else {
    votePolls.value = polls;
  }
}

watchRecords({
  collections: ['polls', 'memberships', 'stances'],
  query: findRecords
});
watch(() => route.query.q, findRecords);

loadPendingPolls();

onMounted(() => {
  EventBus.$emit('currentComponent', {
    titleKey: 'dashboard_page.polls_to_vote_on',
    page: 'pollsToVoteOnPage'
  });
});

function titleVisible(visible) {
  EventBus.$emit('content-title-visible', visible);
}
</script>

<template lang="pug">
v-main
  v-container.polls-to-vote-on-page.max-width-1024.px-0.px-sm-3
    h1.text-headline-large.my-4(tabindex="-1" v-intersect="{handler: titleVisible}" v-t="'dashboard_page.polls_to_vote_on'")

    section.polls-to-vote-on-page__loading(v-if='loading && votePolls.length == 0')
      v-card.mb-2(variant="flat")
        v-list(lines="two")
          loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index')

    section.polls-to-vote-on-page__content(v-if='!loading || votePolls.length > 0')
      v-card.mb-2(v-if='votePolls.length > 0' variant="flat")
        v-list(lines="two")
          poll-common-preview(
            display-group-name
            full-name
            :poll="poll"
            v-for="poll in votePolls"
            :key="poll.id"
          )

      v-card.mb-2(v-if='votePolls.length == 0 && !loading' variant="flat")
        v-card-text(v-t="'dashboard_page.no_polls_to_vote_on'")
</template>
