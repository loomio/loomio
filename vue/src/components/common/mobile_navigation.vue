<script setup lang="js">
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { useDisplay } from 'vuetify';
import { useRoute } from 'vue-router';

import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import { useCurrentUserNotifications } from '@/composables/useCurrentUserNotifications';
import { usePendingPolls } from '@/composables/usePendingPolls';

const display = useDisplay();
const route = useRoute();
const { loadNotifications } = useCurrentUserNotifications();
const { loadPendingPolls, findPendingPolls } = usePendingPolls();

const signedIn = ref(Session.isSignedIn());
let fetched = false;

const visible = computed(() => display.smAndDown.value && signedIn.value);
const activeItem = computed(() => {
  if (route.path === '/dashboard/polls_to_vote_on') return 'votes';
  if (route.path === '/notifications') return 'notifications';
  if (route.path.startsWith('/dashboard')) return 'threads';
  return undefined;
});

const unreadNotifications = computed(() => Records.notifications.find({viewed: {$ne: true}}).length);
const pollsToVoteOn = computed(() => findPendingPolls().length);

function fetchData() {
  if (fetched || !Session.isSignedIn()) return;
  fetched = true;
  loadNotifications();
  loadPendingPolls();
}

function handleSignedIn() {
  signedIn.value = true;
  fetchData();
}

function refreshNotifications() {
  if (Session.isSignedIn()) Records.notifications.fetchNotifications();
}

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
  density="compact"
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
