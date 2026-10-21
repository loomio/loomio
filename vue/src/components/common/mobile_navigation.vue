<script setup lang="js">
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { useDisplay } from 'vuetify';
import { useRoute } from 'vue-router';
import { useI18n } from 'vue-i18n';

import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import { useWatchRecords } from '@/composables/useWatchRecords';

const display = useDisplay();
const route = useRoute();
const { t } = useI18n();
const { watchRecords } = useWatchRecords();

const signedIn = ref(Session.isSignedIn());
const unreadNotifications = ref(0);
const sidebarOpen = ref(false);
const page = ref(null);

const visible = computed(() => display.smAndDown.value && signedIn.value);
const activeItem = computed(() => {
  if (route.path === '/notifications') return 'notifications';
  if (route.path.startsWith('/dashboard')) return 'dashboard';
  return undefined;
});

function updateCounts() {
  unreadNotifications.value = Records.notifications.find({viewed: {$ne: true}}).length;
}

function handleSignedIn() {
  signedIn.value = true;
}

function handleSidebarOpen(open) { sidebarOpen.value = open; }
function handlePage(data) { page.value = data.page; }

function refreshNotifications() {
  if (Session.isSignedIn()) Records.notifications.fetchNotifications().catch(() => {});
}

watchRecords({
  key: 'mobile-navigation',
  collections: ['notifications'],
  query: updateCounts
});

onMounted(() => {
  EventBus.$on('signedIn', handleSignedIn);
  EventBus.$on('sidebarOpen', handleSidebarOpen);
  EventBus.$on('currentComponent', handlePage);
  window.addEventListener('loomio:native-notification', refreshNotifications);
});

onUnmounted(() => {
  EventBus.$off('signedIn', handleSignedIn);
  EventBus.$off('sidebarOpen', handleSidebarOpen);
  EventBus.$off('currentComponent', handlePage);
  window.removeEventListener('loomio:native-notification', refreshNotifications);
});
</script>

<template lang="pug">
v-bottom-navigation.mobile-navigation.lmo-no-print(
  v-if="visible"
  :model-value="activeItem"
  grow
  color="primary"
  bg-color="surface"
)
  v-btn(value="sidebar" :active="sidebarOpen" @click="EventBus.$emit('toggleSidebar')" :aria-expanded="sidebarOpen" :aria-label="t(sidebarOpen ? 'navbar.close_sidebar' : 'navbar.open_sidebar')")
    common-icon(name="mdi-menu")

  v-btn(value="dashboard" to="/dashboard" :aria-label="t('dashboard_page.dashboard')")
    common-icon(name="mdi-view-dashboard-outline")

  v-btn(value="notifications" to="/notifications" :aria-label="t('notifications.header')")
    v-badge(color="primary" :content="unreadNotifications" v-if="unreadNotifications")
      common-icon(name="mdi-bell-outline")
    common-icon(v-else name="mdi-bell-outline")

  v-btn(v-if="page === 'topicPage'" value="contents" @click="EventBus.$emit('toggleTopicNav')" :aria-label="t('navbar.thread_nav')")
    common-icon(name="mdi-menu-open")
</template>

<style>
.mobile-navigation {
  padding-bottom: min(env(safe-area-inset-bottom), 16px);
  /* Navigation taps do not need the browser's double-tap zoom delay. */
  touch-action: manipulation;
}

.mobile-navigation .v-icon {
  font-size: 1.875rem;
}

.mobile-navigation .v-bottom-navigation__content > .v-btn {
  padding: 8px 16px;
}
</style>
