<script lang="js">
import AppConfig           from '@/shared/services/app_config';
import EventBus            from '@/shared/services/event_bus';
import AbilityService      from '@/shared/services/ability_service';
import AuthModalMixin      from '@/mixins/auth_modal';
import Session             from '@/shared/services/session';
import { last }            from 'lodash-es';

export default {
  mixins: [ AuthModalMixin ],
  data() {
    return {
      title: AppConfig.theme.site_name,
      isLoggedIn: Session.isSignedIn(),
      group: null,
      breadcrumbs: null,
      sidebarOpen: false,
      activeTab: '',
      showTitle: true,
      page: null
    };
  },

  methods: {
    toggleSidebar() { EventBus.$emit('toggleSidebar'); },
    toggleThreadNav() { EventBus.$emit('toggleThreadNav'); },
    signIn() { this.openAuthModal(); },
    last,
    openSearchModal() {
      EventBus.$emit('openModal', {
        component: 'SearchModal',
        persistent: false,
        maxWidth: 900,
        props: {
          group: this.group,
          discussion: this.discussion
        }
      }
      );
    }
  },


  mounted() {
    EventBus.$on('sidebarOpen', val => {
      this.sidebarOpen = val;
    });

    EventBus.$on('signedIn', user => {
      this.isLoggedIn = true;
    });

    EventBus.$on('content-title-visible', val => {
      this.showTitle = !val;
    });

    EventBus.$on('currentComponent', data => {
      data = Object.assign({focusHeading: true}, data);
      if (data.title != null) {
        this.title = data.title;
      } else if (data.titleKey != null) {
        this.title = this.$t(data.titleKey);
      }

      this.group = data.group;
      this.discussion = data.discussion;
      this.page = data.page;

      if (data.focusHeading) {
        setTimeout(() => {
          if (document.querySelector('.v-main h1')) {
            document.querySelector('.v-main h1').focus();
          }
        });
      }
    });
  },

  computed: {
    groupName() {
      if (!this.group) { return; }
      return this.group.name;
    },
    parentName() {
      if (!this.group) { return; }
      return this.group.parentOrSelf().name;
    },
    groupPage() { return this.page === 'groupPage'; },
    threadPage() { return this.page === 'threadPage'; },
    logo() {
      return AppConfig.theme.app_logo_src;
    },
    icon() {
      return AppConfig.theme.icon_src;
    }
  }
};
</script>

<template lang="pug">
v-app-bar.lmo-no-print(app clipped-right elevate-on-scroll color="background")
  v-btn.navbar__sidenav-toggle(icon @click="toggleSidebar()" :aria-label="$t(sidebarOpen ? 'navbar.close_sidebar' : 'navbar.open_sidebar')")
    v-avatar(tile size="36px")
      common-icon(name="mdi-menu")
  v-toolbar-title(v-if="showTitle" @click="$vuetify.goTo('head', {duration: 0})") {{title}}
  v-spacer
  v-btn(@click="openSearchModal" icon :title="$t('common.action.search')")
    common-icon(name="mdi-magnify")
  notifications(v-if='isLoggedIn')
  v-toolbar-items
  v-btn.navbar__sign-in(text v-if='!isLoggedIn' v-t="'auth_form.sign_in'" @click='signIn()')
</template>
