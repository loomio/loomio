<script lang="js">
import AppConfig           from '@/shared/services/app_config';
import EventBus            from '@/shared/services/event_bus';
import AbilityService      from '@/shared/services/ability_service';
import AuthModalMixin      from '@/mixins/auth_modal';
import Session             from '@/shared/services/session';
import FormatDate from '@/mixins/format_date';
import SidebarTips from '@/components/sidebar/tips';
import { mergeProps } from 'vue'

import { last }            from 'lodash-es';

export default {
  components: { SidebarTips },
  mixins: [ AuthModalMixin, FormatDate ],
  data() {
    return {
      title: AppConfig.theme.site_name,
      isLoggedIn: Session.isSignedIn(),
      group: null,
      breadcrumbs: null,
      sidebarOpen: false,
      activeTab: '',
      showTitle: true,
      page: null,
      highlightTips: true,
      mergeProps: mergeProps
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
    setTimeout(() => {
      this.highlightTips = false;
    }, 5000)
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
    user() { return Session.user() },
    groupName() {
      if (!this.group) { return; }
      return this.group.name;
    },
    parentName() {
      if (!this.group) { return; }
      return this.group.parentOrSelf().name;
    },
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
  v-app-bar-nav-icon.navbar__sidenav-toggle(v-if='isLoggedIn' @click="toggleSidebar()" :aria-label="$t(sidebarOpen ? 'navbar.close_sidebar' : 'navbar.open_sidebar')")
    common-icon(name="mdi-menu")
  v-app-bar-title(@click="scrollTo('#context')")
    span(v-if="showTitle") {{title}}
  template(v-if='isLoggedIn')
    sidebar-tips(v-if="!user.experiences.hideOnboarding")
    v-btn(@click="openSearchModal" icon :title="$t('common.action.search')")
      common-icon(name="mdi-magnify")
    notifications
  template(v-else)
    v-btn.navbar__sign-in(variant="text" @click='signIn()')
      span(v-t="'auth_form.sign_in'")
</template>
