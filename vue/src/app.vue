<script lang="js">
import AppConfig from '@/shared/services/app_config';
import AuthModalMixin from '@/mixins/auth_modal';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import { each, compact, truncate } from 'lodash';
import openModal from '@/shared/helpers/open_modal';
import { initLiveUpdate, closeLiveUpdate } from '@/shared/helpers/message_bus';
import CustomCss from '@/components/custom_css';
import MaterialIcons from '@/css/materialdesignicons.css';
import Roboto from '@/css/roboto.css';
import Thumbicons from '@/css/thumbicons.css';

export default {
  components: {CustomCss},
  mixins: [AuthModalMixin],
  data() {
    return {pageError: null};
  },

  created() {
    if (this.$route.query.locale) { Session.updateLocale(this.$route.query.locale); }

    if (Session.user().experiences.darkMode != null) {
      this.$vuetify.theme.dark = Session.user().experiences['darkMode'];
    } else {
      this.$vuetify.theme.dark = (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);
    }

    return each(AppConfig.theme.vuetify, (value, key) => {
      if (value) { this.$vuetify.theme.themes.light[key] = value; }
      if (value) { this.$vuetify.theme.themes.dark[key] = value; }
      return true;
    });
  },

  mounted() {
    initLiveUpdate();
    if (!Session.isSignedIn() && this.shouldForceSignIn()) { this.openAuthModal(true); }
    EventBus.$on('currentComponent',     this.setCurrentComponent);
    EventBus.$on('openAuthModal',     () => this.openAuthModal());
    EventBus.$on('pageError', error => { return this.pageError = error; });
    EventBus.$on('signedIn',          () => { return this.pageError = null; });
    EventBus.$on('VueForceUpdate',    () => {
      this.$nextTick(() => {this.$forceUpdate(); });
    });
    if (AppConfig.flash.notice) { Flash.success(AppConfig.flash.notice); }
  },

  destroyed() {
    return closeLiveUpdate();
  },

  watch: {
    '$route'() {
      return this.pageError = null;
    }
  },

  methods: {
    setCurrentComponent(options) {
      this.pageError = null;
      const title = truncate(options.title || this.$t(options.titleKey), {length: 300});
      document.querySelector('title').text = compact([title, AppConfig.theme.site_name]).join(' | ');

      AppConfig.currentGroup      = options.group;
      AppConfig.currentDiscussion = options.discussion;
      return AppConfig.currentPoll       = options.poll;
    },

    shouldForceSignIn(options = {}) {
      if (this.$route.query.sign_in) { return true; }
      if ((AppConfig.pendingIdentity || {}).identity_type != null) { return true; }
      if (Session.isSignedIn()) { return false; }

      switch (this.$route.path) {
        case '/email_preferences': return (Session.user().restricted == null);
        case '/dashboard':      
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
  navbar
  sidebar
  router-view(v-if="!pageError")
  common-error(v-if="pageError" :error="pageError")
  v-spacer
  common-footer
  modal-launcher
  common-flash
</template>

<style lang="sass">

// .strand-page [id]::before
//   content: ''
//   display: block
//   height:      72px
//   margin-top: -72px
//   visibility: hidden

.v-application .text-body-2
  font-size: 15px !important
  letter-spacing: normal !important

h1:focus, h2:focus, h3:focus, h4:focus, h5:focus, h6:focus
  outline: 0
a
  text-decoration: none

.lmo-relative
  position: relative

.text-almost-black
  color: rgba(0, 0, 0, 0.87)

.max-width-640
  max-width: 640px
.max-width-800
  max-width: 800px
.max-width-1024
  max-width: 1024px

@media (prefers-color-scheme: dark)
  body
    background-color: #000

@media print
  .lmo-no-print
    display: none !important

</style>
