<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import InboxService   from '@/shared/services/inbox_service';

import { isUndefined, sortBy, filter, find, head, each, uniq, map, sum, compact,
concat, intersection, difference, orderBy } from 'lodash';

export default {
  data() {
    return {
      organization: null,
      open: false,
      group: null,
      version: AppConfig.version,
      tree: [],
      myGroups: [],
      otherGroups: [],
      organizations: [],
      unreadCounts: {},
      expandedGroupIds: [],
      openGroups: [],
      unreadDirectThreadsCount: 0
    };
  },

  created() {
    EventBus.$on('toggleSidebar', () => { return this.open = !this.open; });

    EventBus.$on('currentComponent', data => {
      this.group = data.group;
      if (this.group) {
        this.organization = data.group.parentOrSelf();
        this.expandedGroupIds = [this.organization.id];
      } else {
        this.organization = null;
      }
    });

    this.watchRecords({
      collections: ['groups', 'memberships', 'discussions'],
      query: store => {
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
    memberGroups(group) {
      return group.subgroups().filter(g => !g.archivedAt && g.membershipFor(Session.user()));
    },

    openIfPinned() {
      this.open = !!Session.isSignedIn() && !!Session.user().experiences['sidebar'] && this.$vuetify.breakpoint.lgAndUp;
    },

    fetchData() {
      Records.users.fetchGroups().then(() => {
        if ((this.$router.history.current.path === "/dashboard") && (Session.user().groups().length === 1)) {
          this.$router.replace(`/g/${Session.user().groups()[0].key}`);
        }
        if ((this.$router.history.current.path === "/dashboard") && (Session.user().groups().length === 0)) {
          this.$router.replace("/g/new");
        }
      });
      InboxService.load();
    },

    goToGroup(group) {
      this.$router.push(this.urlFor(group));
    },

    updateGroups() {
      this.organizations = compact(Session.user().parentGroups().concat(Session.user().orphanParents())) || [];
      this.openCounts = {};
      this.closedCounts = {};
      this.openGroups = [];
      Session.user().groups().forEach(group => {
        this.openCounts[group.id] = filter(group.discussions(), discussion => discussion.isUnread()).length;
      });
      Session.user().parentGroups().forEach(group => {
        if (this.organization && (this.organization.id === group.parentOrSelf().id)) {
          this.openGroups[group.id] = true;
        }
        this.closedCounts[group.id] = this.openCounts[group.id] + sum(map(this.memberGroups(group), subgroup => this.openCounts[subgroup.id]));
      });
    },

    unreadThreadCount() {
      return InboxService.unreadCount();
    },

    canViewPublicGroups() { return AbilityService.canViewPublicGroups(); },
    setProfilePicture() { EventBus.$emit('openModal', {component: 'ChangePictureForm'}); }
  },

  computed: {
    helpURL() { 
      const siteUrl = new URL(AppConfig.baseUrl);
      return `https://help.loomio.com/en/?utm_source=${siteUrl.host}`;
    },
    isSignedIn() { return Session.isSignedIn(); },
    showHelp() { return AppConfig.features.app.help_link; },
    user() { return Session.user(); },
    activeGroup() { if (this.group) { return [this.group.id]; } else { return []; } },
    logoUrl() { return AppConfig.theme.app_logo_src; },
    showContact() { return AppConfig.features.app.show_contact; },
    canStartGroups() { return AbilityService.canStartGroups(); },
    canStartDemo() { return AppConfig.features.app.demos; },
    showTemplateGallery() { return AppConfig.features.app.template_gallery; },
    showExploreGroups() { return AppConfig.features.app.explore_public_groups; },
    needProfilePicture() {
      return Session.isSignedIn() && this.user && !this.user.avatarUrl && !this.user.hasExperienced('changePicture');
    }
  }
};
</script>

<template lang="pug">
v-navigation-drawer.sidenav-left.lmo-no-print(app v-model="open")
  template(v-slot:prepend)
  template(v-slot:append)
    v-layout.mx-10.my-2(column align-center style="max-height: 64px")
      v-img(:src="logoUrl")

  v-list-group.sidebar__user-dropdown
    template(v-slot:activator)
      v-list-item-icon.mr-2
        user-avatar(:user="user")
      v-list-item-content
        v-list-item-title {{user.name}}
        v-list-item-subtitle {{user.email}}
    user-dropdown
  template(v-if="needProfilePicture")
    v-divider
    v-list-item.sidebar__list-item-button--recent(@click="setProfilePicture" color="warning")
      v-list-item-icon
        v-icon mdi-emoticon-outline
      v-list-item-content
        v-list-item-title(v-t="'profile_page.incomplete_profile'")
        v-list-item-subtitle(v-t="'profile_page.set_your_profile_picture'")
  v-divider

  v-list-item.sidebar__list-item-button--recent(dense to="/dashboard")
    v-list-item-title(v-t="'dashboard_page.aria_label'")
  v-list-item(dense to="/inbox")
    v-list-item-title(v-t="{ path: 'sidebar.unread_threads', args: { count: unreadThreadCount() } }")
  v-list-item.sidebar__list-item-button--private(dense to="/threads/direct")
    v-list-item-title
      span(v-t="'sidebar.invite_only_threads'")
      span(v-if="unreadDirectThreadsCount > 0")
        space
        span ({{unreadDirectThreadsCount}})
  v-list-item.sidebar__list-item-button--start-thread(dense to="/d/new")
    v-list-item-title(v-t="'sidebar.start_thread'")
    v-list-item-icon
      v-icon mdi-plus
  v-list-item(dense to="/tasks" :disabled="organizations.length == 0")
    v-list-item-title(v-t="'tasks.tasks'")
  v-divider

  v-list.sidebar__groups(dense)
    template(v-for="parentGroup in organizations")
      template(v-if="memberGroups(parentGroup).length")
        v-list-group(v-model="openGroups[parentGroup.id]" @click="goToGroup(parentGroup)")
          template(v-slot:activator)
            v-list-item-avatar(aria-hidden="true")
              group-avatar(:group="parentGroup")
            v-list-item-content
              v-list-item-title
                span {{parentGroup.name}}
                template(v-if="closedCounts[parentGroup.id]")
                  | &nbsp;
                  span ({{closedCounts[parentGroup.id]}})
          v-list-item(:to="urlFor(parentGroup)+'?subgroups=none'")
            v-list-item-content
              v-list-item-title
                span {{parentGroup.name}}
                template(v-if='openCounts[parentGroup.id]')
                  | &nbsp;
                  span ({{openCounts[parentGroup.id]}})
          v-list-item(v-for="group in memberGroups(parentGroup)", :key="group.id", :to="urlFor(group)")
            v-list-item-content
              v-list-item-title
                span {{group.name}}
                template(v-if='openCounts[group.id]')
                  | &nbsp;
                  span ({{openCounts[group.id]}})
      template(v-else)
        v-list-item(:to="urlFor(parentGroup)")
          v-list-item-avatar
            group-avatar(:group="parentGroup")
          v-list-item-content
            v-list-item-title
              span {{parentGroup.name}}
              template(v-if='openCounts[parentGroup.id]')
                | &nbsp;
                span ({{openCounts[parentGroup.id]}})

    v-list-item.sidebar__list-item-button--start-group(v-if="canStartGroups" to="/g/new")
      v-list-item-avatar
        v-icon(tile) mdi-plus
      v-list-item-title(v-t="'group_form.new_group'")
  v-divider
  v-list-item.sidebar__list-item-button--start-group(v-if="canStartDemo" to="/demo" dense)
    v-list-item-title(v-t="'templates.demo_group'")
    v-list-item-icon
      v-icon mdi-car-convertible
  v-list-item(v-if="showHelp", :href="helpURL" target="_blank" dense)
    v-list-item-title(v-t="'common.help_and_guides'")
    v-list-item-icon
      v-icon mdi-book-open-page-variant
  v-list-item.sidebar__list-item-button--example-templates(v-if="showTemplateGallery" to="/templates" dense)
    v-list-item-title(v-t="'sidebar.examples_and_templates'")
    v-list-item-icon
      v-icon mdi-lightbulb-on
  v-list-item(dense to="/explore" v-if="showExploreGroups")
    v-list-item-title(v-t="'sidebar.explore_groups'")
    v-list-item-icon
      v-icon mdi-map-search
  v-list-item(v-if="showContact" to="/contact" dense)
    v-list-item-title(v-t="'user_dropdown.contact_support'")
    v-list-item-icon
      v-icon mdi-face-agent
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
