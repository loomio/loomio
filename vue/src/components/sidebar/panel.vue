<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import InboxService   from '@/shared/services/inbox_service';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';
import FormatDate from '@/mixins/format_date';

import { compact } from 'lodash-es';
import SidebarSubgroups from '@/components/sidebar/subgroups';
import SidebarSettings from '@/components/sidebar/settings';
import SidebarHelp from '@/components/sidebar/help';

import { mdiPlus, mdiCog } from '@mdi/js';

import { useTheme } from 'vuetify';

var theme = {}

export default {
  components: { SidebarSettings, SidebarSubgroups, SidebarHelp },
  mixins: [WatchRecords, UrlFor, FormatDate],
  data() {
    return {
      mdiPlus, mdiCog,
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
    theme = useTheme();
    this.user = Session.user();

    EventBus.$on('toggleSidebar', () => {
      this.open = !this.open;
      Records.users.saveExperience('sidebar', this.open)
    });

    EventBus.$on('currentComponent', data => {
      // this.page = data.page;

      if (data.group) {
        this.page = 'groupPage'
        this.group = data.group;
        this.organization = data.group.parentOrSelf();
      } else {
        this.group = null;
        this.organization = null;
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
      this.user = Session.user();
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
    unreadThreadCount() {
      return InboxService.unreadCount();
    },

    openIfPinned() {
      this.open = !!Session.isSignedIn() && this.$vuetify.display.lgAndUp && (Session.user().experiences['sidebar'] === undefined) || (Session.user().experiences['sidebar'] == true);
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
  },

  computed: {
    canStartGroups() { return AbilityService.canStartGroups(); },
    greySidebarLogo() {
      return AppConfig.features.app.gray_sidebar_logo_in_dark_mode && theme.global.name.value.startsWith("dark")
    },
    isSignedIn() { return Session.isSignedIn(); },
    activeGroup() { if (this.group) { return [this.group.id]; } else { return []; } },
    logoUrl() { return AppConfig.theme.app_logo_src; },
    showTemplateGallery() { return AppConfig.features.app.template_gallery; },
    showNewThreadButton() { return AppConfig.features.app.new_thread_button; },
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
      v-list-item.sidebar__user-dropdown(nav slim @click.prevent="showSettings = true" :append-icon="mdiCog")
        template(v-slot:prepend)
          user-avatar.mr-2(:user="user" :size="32")
        v-list-item-title {{ user.name }}
        v-list-item-subtitle {{ user.email }}

    v-divider
    v-list(nav density="compact" :lines="false")
      v-list-item.sidebar__list-item-button--recent(to="/dashboard" :title="$t('dashboard_page.aria_label')")
      v-list-item(to="/inbox" :title="$t('sidebar.unread_threads', { count: unreadThreadCount() })")
      v-list-item.sidebar__list-item-button--private(to="/threads/direct")
        v-list-item-title
          span(v-t="'sidebar.invite_only_threads'")
          span(v-if="unreadDirectThreadsCount > 0")
            space
            span ({{unreadDirectThreadsCount}})
      v-list-item(to="/tasks" :disabled="organizations.length == 0" :title="$t('tasks.tasks')")

    v-divider
    v-list.sidebar__groups(nav density="comfortable")
      v-list-subheader
        span(v-t="'common.organizations'")
      template(v-for="group in organizations" :key="group.id")
        v-list-item(:to="urlFor(group)")
          template(v-slot:prepend)
            group-avatar.mr-2(:group="group")
          v-list-item-title
            span {{group.name}}
            template(v-if='openCounts[group.id]')
              | &nbsp;
              span ({{openCounts[group.id]}})
        sidebar-subgroups(v-if="group == organization" :organization="group" :open-counts="openCounts")

      v-btn.sidebar-start-group(
        block
        variant="tonal"
        color="primary"
        v-if="canStartGroups"
        to="/g/new"
      )
        span(v-t="'sidebar.start_group'")

    v-divider

    sidebar-help

  template(v-slot:append)
    v-divider
    v-layout.mx-13.my-3(column align-center style="max-height: 64px" :class="{greySidebarLogo: greySidebarLogo}")
      v-img(:src="logoUrl")

</template>
<style lang="sass">
.greySidebarLogo
  filter: saturate(99999%) grayscale(1)
</style>
