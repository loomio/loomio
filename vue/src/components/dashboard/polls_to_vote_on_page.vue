<script setup lang="js">
import { ref, onMounted, onUnmounted } from 'vue';
import { useRoute } from 'vue-router';
import { escapeRegExp, filter } from 'lodash-es';
import { subDays } from 'date-fns';

import Records from '@/shared/services/records';
import RecordLoader from '@/shared/services/record_loader';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';

const route = useRoute();

const votePolls = ref([]);
const loader = ref(null);
const watchedRecords = ref([]);

const watchRecordsFunc = (options) => {
  const { collections, query, key } = options;
  const name = collections.concat(key || parseInt(Math.random() * 10000)).join('_');
  watchedRecords.value.push(name);
  Records.view({
    name,
    collections,
    query
  });
};

const findRecords = () => {
  const groupIds = Session.user().groupIds();
  const pollIds = Records.stances.find({myStance: true}).map(stance => stance.pollId);

  let chain = Records.polls.collection.chain();
  chain = chain.find({discardedAt: null, closingAt: {$ne: null}});
  chain = chain.find({$or: [{groupId: {$in: groupIds}}, {id: {$in: pollIds}}, {authorId: Session.user().id}]});
  chain = chain.find({$or: [{closedAt: null}, {closedAt: {$gt: subDays(new Date, 3)}}]});

  if (route.query.q) {
    const rx = new RegExp(escapeRegExp(route.query.q), 'i');
    chain = chain.find({$or: [{'title': {'$regex': rx}},
                             {'description': {'$regex': rx}}]});
  }

  const votable = p => p.iCanVote() && !p.iHaveVoted();
  votePolls.value = filter(chain.simplesort('closingAt', true).data(), votable);
};

loader.value = new RecordLoader({
  collection: 'polls',
  params: {
    exclude_types: 'group',
    status: 'recent'
  }
});

loader.value.fetchRecords();

watchRecordsFunc({
  collections: ['polls', 'groups', 'memberships', 'stances'],
  query: () => findRecords()
});

onMounted(() => {
  EventBus.$emit('currentComponent', {
    titleKey: 'dashboard_page.polls_to_vote_on',
    page: 'pollsToVoteOnPage'
  });
});

onUnmounted(() => {
  watchedRecords.value.forEach(name => delete Records.views[name]);
});

const titleVisible = (visible) => {
  EventBus.$emit('content-title-visible', visible);
};
</script>

<template lang="pug">
v-main
  v-container.polls-to-vote-on-page.max-width-1024.px-0.px-sm-3
    h1.text-headline-large.my-4(tabindex="-1" v-intersect="{handler: titleVisible}" v-t="'dashboard_page.polls_to_vote_on'")
    
    section.polls-to-vote-on-page__loading(v-if='loader.loading && votePolls.length == 0')
      v-card.mb-2
        v-list(lines="two")
          loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index')
    
    section.polls-to-vote-on-page__content(v-if='!loader.loading || votePolls.length > 0')
      v-card.mb-2(v-if='votePolls.length > 0')
        v-list(lines="two")
          poll-common-preview(
            display-group-name
            full-name
            :poll="poll"
            v-for="poll in votePolls"
            :key="poll.id"
          )
      
      v-card.mb-2(v-if='votePolls.length == 0 && !loader.loading')
        v-card-text(v-t="'dashboard_page.no_polls_to_vote_on'")
</template>
