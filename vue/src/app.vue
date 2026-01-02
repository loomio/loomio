<script lang="js">
import AppConfig from '@/shared/services/app_config';
import AuthModalMixin from '@/mixins/auth_modal';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import { compact, truncate } from 'lodash-es';
import { initLiveUpdate, closeLiveUpdate } from '@/shared/helpers/message_bus';


import { useTheme } from 'vuetify';

import SidebarPanel from '@/components/sidebar/panel';

export default {
  components: [SidebarPanel],
  mixins: [AuthModalMixin],

  data() {
    return {pageError: null};
  },

  created() {
    const theme = useTheme();

    Object.entries(AppConfig.theme.light).forEach(([key, value]) => {
      if (value) { theme.themes.value.light.colors[key] = value; }
    });

    Object.entries(AppConfig.theme.lightblue).forEach(([key, value]) => {
      if (value) { theme.themes.value.lightBlue.colors[key] = value; }
    });

    Object.entries(AppConfig.theme.dark).forEach(([key, value]) => {
      if (value) { theme.themes.value.dark.colors[key] = value; }
    });

    Object.entries(AppConfig.theme.darkblue).forEach(([key, value]) => {
      if (value) { theme.themes.value.darkBlue.colors[key] = value; }
    });

    if (Session.user().experiences.theme != null) {
      theme.change(Session.user().experiences['theme']);
    } else {
      theme.change( (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) ? AppConfig.theme.default_dark_theme : AppConfig.theme.default_light_theme )
    }
  },

  mounted() {
    initLiveUpdate();
    EventBus.$on('currentComponent',     this.setCurrentComponent);
    EventBus.$on('openAuthModal',     () => this.openAuthModal());
    EventBus.$on('pageError', error => { return this.pageError = error; });
    EventBus.$on('signedIn',          () => { return this.pageError = null; });
    if (AppConfig.flash.notice) { Flash.success(AppConfig.flash.notice); }
  },

  destroyed() {
    closeLiveUpdate();
  },

  watch: {
    '$route'() {
      if (!Session.isSignedIn() && this.shouldForceSignIn()) { this.openAuthModal(true); }
      this.pageError = null;
    }
  },

  methods: {
    setCurrentComponent(options) {
      this.pageError = null;
      const title = truncate(options.title || this.$t(options.titleKey), {length: 300});
      document.querySelector('title').text = compact([title, AppConfig.theme.site_name]).join(' | ');

      AppConfig.currentGroup      = options.group;
      AppConfig.currentDiscussion = options.discussion;
      AppConfig.currentPoll       = options.poll;
    },

    shouldForceSignIn(options = {}) {
      if (this.$route.query.sign_in) { return true; }
      if ((AppConfig.pendingIdentity || {}).identity_type != null) { return true; }
      if (Session.isSignedIn()) { return false; }

      switch (this.$route.path) {
        case '/email_preferences': return (Session.user().restricted == null);
        case '/dashboard': return true;
        case '/inbox':
        case '/profile':
        case '/polls':
        case '/p/new':
        case '/g/new': return true;
      }
    }
  }
};

</script>

<template lang="pug">
v-app.app-is-booted
  system-notice
  sidebar-panel
  navbar
  router-view(v-if="!pageError")
  common-error(v-if="pageError" :error="pageError")
  v-spacer
  modal-launcher
  common-flash
</template>

<style lang="sass">
@import '@/css/utilities.scss'
@import '@/css/roboto.css'
@import '@/css/thumbicons.css'
@import '@/css/print.scss'

.underline-on-hover:hover
  text-decoration: underline

.v-card.group-form > .v-card__content
  overflow: visible!important

.v-card.discussion-form,
.v-card.thread-template-form,
.v-card.thread-template-form .v-card-item__content,
.v-card.discussion-form .v-card-item__content,
.v-card.poll-common-modal,
.v-card.poll-common-modal .v-card-item__content
  overflow: visible!important

.text-on-surface
  color: rgba(var(--v-theme-on-surface), var(--v-high-emphasis-opacity))

.text-transform-none
  text-transform: none

h1:focus, h2:focus, h3:focus, h4:focus, h5:focus, h6:focus
  outline: 0

a
  text-decoration: none
  color: rgb(var(--v-theme-anchor))

.lmo-relative
  position: relative

.text-almost-black
  color: rgba(0, 0, 0, 0.87)

.max-width-320
  max-width: 320px !important
.max-width-400
  max-width: 400px !important
.max-width-640
  max-width: 640px !important
.max-width-800
  max-width: 800px !important
.max-width-900
  max-width: 900px !important
.max-width-1024
  max-width: 1024px !important

@media (prefers-color-scheme: dark)
  body
    background-color: #000

@media print
  .lmo-no-print
    display: none !important

</style>
