<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import InboxService   from '@/shared/services/inbox_service';
import ThreadService   from '@/shared/services/thread_service';
import PlausibleService from '@/shared/services/plausible_service';
import Flash from '@/shared/services/flash';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';
import FormatDate from '@/mixins/format_date';

import { map, sum, compact } from 'lodash-es';
import { useTheme } from 'vuetify';
import SidebarDashboard from '@/components/sidebar/dashboard';
import SidebarGroup from '@/components/sidebar/group';
import SidebarDiscussion from '@/components/sidebar/discussion';
import SidebarSettings from '@/components/sidebar/settings';

export default {
  components: {SidebarSettings, SidebarDashboard, SidebarGroup, SidebarDiscussion},
  mixins: [WatchRecords, UrlFor, FormatDate],
  data() {
    return {
      page: 'dashboardPage',
      organization: null,
      discussions: [],
      discussionsGroup: null,
      open: false,
      group: null,
      version: AppConfig.version,
      tree: [],
      myGroups: [],
      otherGroups: [],
      organizations: [],
      unreadCounts: {},
      openGroups: [],
      openCounts: {},
      unreadDirectThreadsCount: 0,
      showSettings: false
    };
  },

  created() {
    EventBus.$on('toggleSidebar', () => { return this.open = !this.open; });

    EventBus.$on('currentComponent', data => {
      this.page = data.page;

      if (data.group) {
        this.group = data.group;
        this.organization = data.group.parentOrSelf();
      } else {
        this.group = null;
        this.organization = null;
      }

      if (data.discussions) {
        this.discussions = data.discussions;
        this.discussionsGroup = data.discussionsGroup;
      }

      if (this.page == "discussionPage" && this.discussions.length == 0) {
        this.discussions = ThreadService.dashboardQuery();
      }
    });

    this.watchRecords({
      collections: ['groups', 'memberships', 'discussions'],
      query: () => {
        this.unreadDirectThreadsCount =
          Records.discussions.collection.chain().
          find({groupId: null}).
          where(thread => thread.isUnread()).data().length;
        this.updateGroups();
      }
    });

    EventBus.$on('signedIn', user => {
      this.fetchData();
      this.openIfPinned();
    });

    if (Session.isSignedIn()) { return this.fetchData(); }
  },

  mounted() {
    this.openIfPinned();
  },

  watch: {
    organization: 'updateGroups',

    open(val) {
      EventBus.$emit("sidebarOpen", val);
    }
  },

  methods: {
    openIfPinned() {
      this.open = !!Session.isSignedIn() && !!Session.user().experiences['sidebar'] && this.$vuetify.display.lgAndUp;
    },

    fetchData() {
      Records.users.findOrFetchGroups().then(() => {
        if (this.$route.path == "/dashboard") {
          if (Session.user().groups().length == 0) {
            this.$router.replace("/g/new");
          }
          if (Session.user().groups().length == 1) {
              this.$router.replace(`/g/${Session.user().groups()[0].key}`);
          }
        }
      });
      InboxService.load();
    },

    updateGroups() {
      this.organizations = compact(Session.user().parentGroups().concat(Session.user().orphanParents())) || [];
      this.openCounts = {};
      this.openGroups = [];
      Session.user().groups().forEach(group => {
        this.openCounts[group.id] = group.discussions().filter(discussion => discussion.isUnread()).length;
      });
      Session.user().parentGroups().forEach(group => {
        if (this.organization && (this.organization.id === group.parentOrSelf().id)) {
          this.openGroups[group.id] = true;
        }
      });
    },

    setProfilePicture() { EventBus.$emit('openModal', {component: 'ChangePictureForm'}); },
  },

  computed: {
    greySidebarLogo() {
      return AppConfig.features.app.gray_sidebar_logo_in_dark_mode && this.$vuetify.theme.dark
    },
    isSignedIn() { return Session.isSignedIn(); },
    user() { return Session.user(); },
    activeGroup() { if (this.group) { return [this.group.id]; } else { return []; } },
    logoUrl() { return AppConfig.theme.app_logo_src; },
    showTemplateGallery() { return AppConfig.features.app.template_gallery; },
    showExploreGroups() { return AppConfig.features.app.explore_public_groups; },
    showNewThreadButton() { return AppConfig.features.app.new_thread_button; },
    needProfilePicture() {
      return Session.isSignedIn() && this.user && !this.user.avatarUrl && !this.user.hasExperienced('changePicture');
    }
  }
};
</script>

<template lang="pug">
v-navigation-drawer.sidenav-left.lmo-no-print(app v-model="open")
  sidebar-settings(
    v-if="showSettings"
    @closeSettings="showSettings = false"
  )

  template(v-else)
    v-list(nav)
      v-list-item(nav slim to="/dashboard")
        template(v-slot:prepend)
          user-avatar.mr-2(:user="user" :size="32")
        template(v-slot:append)
          v-btn(variant="text" size="small" icon @click="showSettings = true" @click.prevent)
            common-icon(name="mdi-cog")
        v-list-item-title {{ user.name }}
        v-list-item-subtitle 4 unread, 1 vote
      template(v-if="needProfilePicture")
        v-divider
        v-list-item.sidebar__list-item-button--recent(@click="setProfilePicture" color="warning")
          template(v-slot:prepend)
            common-icon(name="mdi-emoticon-outline")
          v-list-item-title(v-t="'profile_page.incomplete_profile'")
          v-list-item-subtitle(v-t="'profile_page.set_your_profile_picture'")
    //- v-divider.my-2
    sidebar-group(
      v-if="page == 'groupPage'"
      :organization="organization"
      :open-counts="openCounts"
    )

    sidebar-discussion(
      v-else-if="page == 'discussionPage'"
      :open-counts="openCounts"
      :discussions="discussions"
      :discussionsGroup="discussionsGroup"
    )

    sidebar-dashboard(
      v-else
      :organizations="organizations"
      :open-counts="openCounts"
      :unread-direct-threads-count="unreadDirectThreadsCount"
    )

  template(v-slot:append)
    v-divider
    v-layout.mx-13.my-3(column align-center style="max-height: 64px" :class="{greySidebarLogo: greySidebarLogo}")
      v-img(:src="logoUrl")

</template>
<style lang="sass">

.sidenav-left
  .v-avatar.v-list-item__avatar
    margin-right: 8px
  .v-list-group .v-list-group__header .v-list-item__icon.v-list-group__header__append-icon
    min-width: 0
  .v-list-item__icon.v-list-group__header__append-icon
    min-width: 32px
  .v-list-item__icon.v-list-group__header__append-icon
    margin-left: 0 !important
</style>
