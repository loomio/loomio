<script setup lang="js">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useDisplay } from 'vuetify';
import AppConfig from '@/shared/services/app_config';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import ScrollService from '@/shared/services/scroll_service';

const { t } = useI18n();
const display = useDisplay();

const title = ref(AppConfig.theme.site_name);
const isLoggedIn = ref(Session.isSignedIn());
const group = ref(null);
const discussion = ref(null);
const sidebarOpen = ref(false);
const showTitle = ref(true);
const appBarScrolled = ref(false);
const page = ref(null);

const isMobile = computed(() => display.smAndDown.value);
const isDesktop = computed(() => display.mdAndUp.value);

function toggleSidebar() { EventBus.$emit('toggleSidebar'); }
function toggleTopicNav() { EventBus.$emit('toggleTopicNav'); }
function signIn() { EventBus.$emit('openModal', { component: 'AuthModal', props: { preventClose: false } }); }
function scrollToContext() { ScrollService.scrollTo('#context'); }

function openSearchModal() {
  EventBus.$emit('openModal', {
    component: 'SearchModal',
    persistent: false,
    maxWidth: 900,
    props: {
      group: group.value,
      discussion: discussion.value
    }
  });
}

function handleSidebarOpen(val) {
  sidebarOpen.value = val;
}

function handleSignedIn() {
  isLoggedIn.value = true;
}

function handleContentTitleVisible(val) {
  showTitle.value = !val;
  appBarScrolled.value = !val;
}

function handleCurrentComponent(rawData) {
  const sameContext =
    rawData.page === page.value &&
    (rawData.group?.id ?? null) === (group.value?.id ?? null) &&
    (rawData.discussion?.id ?? null) === (discussion.value?.id ?? null);
  const data = Object.assign({ focusHeading: !sameContext }, rawData);

  if (data.title != null) {
    title.value = data.title;
  } else if (data.titleKey != null) {
    title.value = t(data.titleKey);
  }

  group.value = data.group;
  discussion.value = data.discussion;
  page.value = data.page;

  if (data.focusHeading) {
    setTimeout(() => {
      document.querySelector('.v-main h1')?.focus();
    });
  }
}

onMounted(() => {
  EventBus.$on('sidebarOpen', handleSidebarOpen);
  EventBus.$on('signedIn', handleSignedIn);
  EventBus.$on('content-title-visible', handleContentTitleVisible);
  EventBus.$on('currentComponent', handleCurrentComponent);
});

onBeforeUnmount(() => {
  EventBus.$off('sidebarOpen', handleSidebarOpen);
  EventBus.$off('signedIn', handleSignedIn);
  EventBus.$off('content-title-visible', handleContentTitleVisible);
  EventBus.$off('currentComponent', handleCurrentComponent);
});
</script>

<template lang="pug">
v-app-bar.lmo-no-print(
  app
  clipped-right
  color="appbar"
  :class="{'navbar--scrolled': appBarScrolled}"
  :density="isMobile ? 'compact' : 'default'"
)
  v-app-bar-nav-icon.navbar__sidenav-toggle(
    v-if="isLoggedIn && isDesktop"
    @click="toggleSidebar"
    :aria-label="t(sidebarOpen ? 'navbar.close_sidebar' : 'navbar.open_sidebar')"
  )
    common-icon(name="mdi-menu")
  v-app-bar-title(@click="scrollToContext")
    span(v-if="showTitle") {{ title }}
  template(v-if="isLoggedIn")
    v-btn.navbar__search(v-if="isDesktop" @click="openSearchModal" icon :title="t('common.action.search')")
      common-icon(name="mdi-magnify")
    notifications(v-if="isDesktop")
  template(v-else)
    v-btn.navbar__sign-in(variant="text" @click="signIn")
      span {{ t('auth_form.sign_in') }}
    v-btn(v-if="page === 'topicPage' && isMobile" icon @click="toggleTopicNav" :aria-label="t('navbar.thread_nav')")
      common-icon(name="mdi-menu-open")
</template>

<style>
.v-app-bar.navbar--scrolled {
  background-color: rgb(var(--v-theme-appbar-scrolled)) !important;
  color: rgb(var(--v-theme-on-appbar-scrolled)) !important;
}

.v-theme--light .v-app-bar.navbar--scrolled {
  background: var(--loomio-theme-light-background-gradient, rgb(var(--v-theme-appbar-scrolled))) !important;
  background-attachment: fixed !important;
  color: var(--loomio-theme-light-background-foreground, rgb(var(--v-theme-on-appbar-scrolled))) !important;
}

.v-theme--dark .v-app-bar.navbar--scrolled {
  background: var(--loomio-theme-dark-background-gradient, rgb(var(--v-theme-appbar-scrolled))) !important;
  background-attachment: fixed !important;
  color: var(--loomio-theme-dark-background-foreground, rgb(var(--v-theme-on-appbar-scrolled))) !important;
}
</style>
