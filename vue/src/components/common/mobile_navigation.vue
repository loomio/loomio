<script setup lang="js">
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { useDisplay } from 'vuetify';
import { useRoute } from 'vue-router';

import EventBus from '@/shared/services/event_bus';
import RecordLoader from '@/shared/services/record_loader';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import { useWatchRecords } from '@/composables/useWatchRecords';

const display = useDisplay();
const route = useRoute();
const { watchRecords } = useWatchRecords();

const signedIn = ref(Session.isSignedIn());
const unreadNotifications = ref(0);
const pollsToVoteOn = ref(0);
let fetched = false;

const visible = computed(() => display.smAndDown.value && signedIn.value);
const activeItem = computed(() => {
  if (route.path === '/dashboard/polls_to_vote_on') return 'votes';
  if (route.path === '/notifications') return 'notifications';
  if (route.path.startsWith('/dashboard')) return 'threads';
  return undefined;
});

function updateCounts() {
  unreadNotifications.value = Records.notifications.find({viewed: {$ne: true}}).length;
  const groupIds = Session.user().groupIds();
  const pollIds = Records.stances.find({myStance: true}).map(stance => stance.pollId);
  const polls = Records.polls.collection.chain()
    .find({discardedAt: null, closingAt: {$ne: null}, closedAt: null})
    .find({$or: [
      {groupId: {$in: groupIds}},
      {id: {$in: pollIds}},
      {authorId: Session.user().id}
    ]})
    .data();
  pollsToVoteOn.value = polls
    .filter(poll => poll.iCanVote() && !poll.iHaveVoted()).length;
}

function fetchData() {
  if (fetched || !Session.isSignedIn()) return;
  fetched = true;
  Records.notifications.fetchNotifications();
  Records.stances.fetch({path: 'my_stances'});
  new RecordLoader({
    collection: 'polls',
    params: {exclude_types: 'group reaction', status: 'recent'}
  }).fetchRecords();
}

function handleSignedIn() {
  signedIn.value = true;
  fetchData();
}

function refreshNotifications() {
  if (Session.isSignedIn()) Records.notifications.fetchNotifications();
}

watchRecords({
  key: 'mobile-navigation',
  collections: ['memberships', 'notifications', 'polls', 'stances'],
  query: updateCounts
});

onMounted(() => {
  fetchData();
  EventBus.$on('signedIn', handleSignedIn);
  window.addEventListener('loomio:native-notification', refreshNotifications);
});

onUnmounted(() => {
  EventBus.$off('signedIn', handleSignedIn);
  window.removeEventListener('loomio:native-notification', refreshNotifications);
});
</script>

<template lang="pug">
v-bottom-navigation.mobile-navigation.lmo-no-print(
  v-if="visible"
  :model-value="activeItem"
  grow
  mode="shift"
  height="88"
  color="primary"
  bg-color="surface"
)
  v-btn(value="threads" to="/dashboard" :aria-label="$t('common.threads')")
    common-icon(name="mdi-forum-outline")
    span(v-t="'common.threads'")

  v-btn(value="votes" to="/dashboard/polls_to_vote_on" :aria-label="$t('poll_common.votes')")
    v-badge(color="primary" :content="pollsToVoteOn" v-if="pollsToVoteOn")
      common-icon(name="mdi-checkbox-marked-circle-outline")
    common-icon(v-else name="mdi-checkbox-marked-circle-outline")
    span(v-t="'poll_common.votes'")

  v-btn(value="notifications" to="/notifications" :aria-label="$t('notifications.header')")
    v-badge(color="primary" :content="unreadNotifications" v-if="unreadNotifications")
      common-icon(name="mdi-bell-outline")
    common-icon(v-else name="mdi-bell-outline")
    span(v-t="'notifications.header'")
</template>

<style>
.mobile-navigation {
  padding-bottom: min(env(safe-area-inset-bottom), 16px);
}

.mobile-navigation .v-icon {
  font-size: 1.875rem;
}
</style>
