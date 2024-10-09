<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import InboxService   from '@/shared/services/inbox_service';
import PlausibleService from '@/shared/services/plausible_service';
import Flash from '@/shared/services/flash';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

import { map, sum, compact } from 'lodash-es';
import { useTheme } from 'vuetify';

export default {
  mixins: [WatchRecords, UrlFor],
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
      unreadDirectThreadsCount: 0,
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

    goToGroup(group) {
      this.$router.push(this.urlFor(group));
    },

    updateGroups() {
      // console.log('AppConfig.currentUserId', AppConfig.currentUserId);
      // console.log('AppConfig', AppConfig);
      // console.log('session user id', Session.user().id);
      // console.log('session user', Session.user())
      // console.log('Records user', Records.users.find(1))
      // console.log('this.$vuetify.display', this.$vuetify.display.xs)
      this.organizations = compact(Session.user().parentGroups().concat(Session.user().orphanParents())) || [];
      this.openCounts = {};
      this.closedCounts = {};
      this.openGroups = [];
      Session.user().groups().forEach(group => {
        this.openCounts[group.id] = group.discussions().filter(discussion => discussion.isUnread()).length;
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
    setProfilePicture() { EventBus.$emit('openModal', {component: 'ChangePictureForm'}); },
    startOrFindDemo() {
      let group;
      if (group = Session.user().parentGroups().find(g => g.subscription.plan == 'demo')) {
        Flash.success('templates.login_to_start_demo');
        let url = this.urlFor(group);
        if (this.$route.path != url) { this.$router.replace(url); }
      } else {
        PlausibleService.trackEvent('start_demo');
        Flash.wait('templates.generating_demo');
        Records.post({path: 'demos/clone'}).then(data => {
          Flash.success('templates.demo_created');
          this.$router.push(this.urlFor(Records.groups.find(data.groups[0].id)));
        })
      }
    }
  },

  computed: {
    logoColor() {
      const theme = useTheme();
      try {
        return theme.current.value.colors.primary;
      } catch {
        return "#DCA034";
      }
    },
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
    showNewThreadButton() { return AppConfig.features.app.new_thread_button; },
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
    v-divider
    v-layout.mx-13.my-3(column align-center :style="{'max-height': '64px', 'color': logoColor}")
      <svg style="width: auto; height: auto" height="96" viewBox="0 0 600 96" width="600" xmlns="http://www.w3.org/2000/svg"><g fill="currentColor"><path d="m588.093039 96c-3.349396 0-6.201584-1.1604958-8.558566-3.4805024-2.355982-2.4431492-3.534473-5.3128643-3.534473-8.6111157 0-3.1751088 1.178491-5.9236516 3.534473-8.2436582 2.356982-2.4431491 5.20917-3.6647237 8.558566-3.6647237 3.348395 0 6.139557 1.1604958 8.371488 3.4814876 2.356981 2.3200065 3.535473 5.1296281 3.535473 8.4268943 0 3.2982514-1.178492 6.1679665-3.535473 8.6111157-2.231931 2.3200066-5.023093 3.4805024-8.371488 3.4805024z"/><path d="m521 96c-9.071381 0-17.260054-2.0619973-24.567025-6.1869973-7.30697-4.2506703-13.039543-10.0003351-17.196715-17.25-4.158177-7.3753351-6.23626-15.5630027-6.23626-24.5630027s2.078083-17.1253351 6.23626-24.3750001c4.157172-7.375335 9.889745-13.1249999 17.196715-17.2499999 7.306971-4.24966488 15.495644-6.375 24.567025-6.375 9.070375 0 17.260054 2.12533512 24.567023 6.375 7.306972 4.125 13.039545 9.8746649 17.196717 17.2499999 4.157172 7.249665 6.23626 15.3750001 6.23626 24.3750001s-2.079088 17.1876676-6.23626 24.5630027c-4.157172 7.2496649-9.889745 12.9993297-17.196717 17.25-7.306969 4.125-15.496648 6.1869973-24.567023 6.1869973zm0-16.3119973c8.944705 0 16.251676-2.9376676 21.920912-8.8130026 5.669235-6 8.504356-13.624665 8.504356-22.8750001s-2.835121-16.8126676-8.504356-22.6869973c-5.669236-6-12.976207-9-21.920912-9-8.94571 0-16.252681 3-21.921917 9-5.669236 5.8743297-8.503351 13.4366622-8.503351 22.6869973s2.834115 16.8750001 8.503351 22.8750001c5.669236 5.875335 12.976207 8.8130026 21.921917 8.8130026z"/><path d="m439 2h17v94h-17z"/><path d="m297 1.13833183h16.967966v11.38331847c2.486823-3.79409889 5.90457-6.82999109 10.256259-9.10665478 4.350683-2.27666369 9.136133-3.41499552 14.357355-3.41499552 10.939608 0 19.14381 4.61668156 24.613614 13.8500447 6.961294-9.23336314 16.222221-13.8500447 27.783785-13.8500447 9.323323 0 16.656988 2.84582961 22.003004 8.53748883 5.345009 5.56495077 8.018017 13.72333627 8.018017 24.47413467v62.9883765h-16.968971v-59.1932558c0-6.4508879-1.553888-11.4466726-4.661662-14.9883766-3.107775-3.6684123-7.520855-5.5015965-13.23924-5.5015965-5.469804 0-9.944275 1.8965384-13.425425 5.6916591-3.480144 3.6673905-5.221222 8.600843-5.221222 14.798314v59.1932558h-16.967966v-59.1932558c0-6.4508879-1.616284-11.4466726-4.847846-14.9883766-3.107775-3.6684123-7.458458-5.5015965-13.053056-5.5015965-5.469803 0-9.944274 1.8965384-13.425425 5.6916591-3.480143 3.6673905-5.221221 8.600843-5.221221 14.798314v59.1932558h-16.967966z"/><path d="m238 96c-9.071381 0-17.260054-2.0619973-24.567023-6.1869973-7.306972-4.2506703-13.039545-10.0003351-17.196717-17.25-4.158177-7.3753351-6.23626-15.5630027-6.23626-24.5630027s2.078083-17.1253351 6.23626-24.3750001c4.157172-7.375335 9.889745-13.1249999 17.196717-17.2499999 7.306969-4.24966488 15.495642-6.375 24.567023-6.375 9.070375 0 17.260054 2.12533512 24.567025 6.375 7.30697 4.125 13.039543 9.8746649 17.196715 17.2499999 4.157172 7.249665 6.23626 15.3750001 6.23626 24.3750001s-2.079088 17.1876676-6.23626 24.5630027c-4.157172 7.2496649-9.889745 12.9993297-17.196715 17.25-7.306971 4.125-15.49665 6.1869973-24.567025 6.1869973zm0-16.3119973c8.944705 0 16.251676-2.9376676 21.920912-8.8130026 5.669235-6 8.504356-13.624665 8.504356-22.8750001s-2.835121-16.8126676-8.504356-22.6869973c-5.669236-6-12.976207-9-21.920912-9-8.94571 0-16.252681 3-21.921917 9-5.669236 5.8743297-8.503351 13.4366622-8.503351 22.6869973s2.834115 16.8750001 8.503351 22.8750001c5.669236 5.875335 12.976207 8.8130026 21.921917 8.8130026z"/><path d="m133 96c-9.071381 0-17.260054-2.0619973-24.567023-6.1869973-7.306972-4.2506703-13.0395454-10.0003351-17.1967169-17.25-4.158177-7.3753351-6.2362601-15.5630027-6.2362601-24.5630027s2.0780831-17.1253351 6.2362601-24.3750001c4.1571715-7.375335 9.8897449-13.1249999 17.1967169-17.2499999 7.306969-4.24966488 15.495642-6.375 24.567023-6.375 9.070375 0 17.260054 2.12533512 24.567025 6.375 7.30697 4.125 13.039543 9.8746649 17.196715 17.2499999 4.157172 7.249665 6.23626 15.3750001 6.23626 24.3750001s-2.079088 17.1876676-6.23626 24.5630027c-4.157172 7.2496649-9.889745 12.9993297-17.196715 17.25-7.306971 4.125-15.49665 6.1869973-24.567025 6.1869973zm-.425268-16.3119973c8.819681 0 16.024518-2.9376676 21.614513-8.8130026 5.589994-6 8.385487-13.624665 8.385487-22.8750001s-2.795493-16.8126676-8.385487-22.6869973c-5.589995-6-12.794832-9-21.614513-9-8.820672 0-16.02551 3-21.615504 9-5.589995 5.8743297-8.384496 13.4366622-8.384496 22.6869973s2.794501 16.8750001 8.384496 22.8750001c5.589994 5.875335 12.794832 8.8130026 21.615504 8.8130026z"/><path d="m0 0h17.0293155v79.7603887h60.9706845v16.2396113h-78z"/></g></svg>

  v-list(density="compact" nav slim :lines="'one'")
    v-list-group.sidebar__user-dropdown
      template(v-slot:activator="{ props }")
        v-list-item(v-bind="props")
          template(v-slot:prepend)
            user-avatar.mr-2(:user="user")
          v-list-item-title {{user.name}}
          v-list-item-subtitle {{user.email}}
      v-list(density="compact" nav)
        user-dropdown
        v-divider
    template(v-if="needProfilePicture")
      v-divider
      v-list-item.sidebar__list-item-button--recent(@click="setProfilePicture" color="warning")
        template(v-slot:prepend)
          common-icon(name="mdi-emoticon-outline")
        v-list-item-title(v-t="'profile_page.incomplete_profile'")
        v-list-item-subtitle(v-t="'profile_page.set_your_profile_picture'")

    v-list-item.sidebar__list-item-button--recent(
       nav slim
      to="/dashboard" :title="$t('dashboard_page.aria_label')")
    v-list-item(
       nav slim
      to="/inbox" :title="$t('sidebar.unread_threads', { count: unreadThreadCount() })")
    v-list-item.sidebar__list-item-button--private(
       nav slim
      to="/threads/direct")
      v-list-item-title
        span(v-t="'sidebar.invite_only_threads'")
        span(v-if="unreadDirectThreadsCount > 0")
          space
          span ({{unreadDirectThreadsCount}})
    v-list-item.sidebar__list-item-button--start-thread(
       nav slim
      v-if="showNewThreadButton"
      to="/d/new" 
      :title="$t('sidebar.start_thread')")
      template(v-slot:append)
        common-icon(name="mdi-plus")
    v-list-item(
      nav slim
      to="/tasks"
      :disabled="organizations.length == 0" :title="$t('tasks.tasks')")
    v-divider
    v-list-subheader
      span(v-t="'common.groups'")

    template(v-for="parentGroup in organizations")
      template(v-if="memberGroups(parentGroup).length")
        v-list-group.sidebar__groups(v-model="openGroups[parentGroup.id]")
          template(v-slot:activator="{props}")
            v-list-item(nav slim v-bind="props")
              template(v-slot:prepend)
                group-avatar(:group="parentGroup").mr-4
              v-list-item-title
                span {{parentGroup.name}}
                template(v-if="closedCounts[parentGroup.id]")
                  | &nbsp;
                  span ({{closedCounts[parentGroup.id]}})
          v-list-item(nav slim :to="urlFor(parentGroup)")
            v-list-item-title
              span {{parentGroup.name}}
              template(v-if='openCounts[parentGroup.id]')
                | &nbsp;
                span ({{openCounts[parentGroup.id]}})
          v-list-item(
            nav slim 
            v-for="group in memberGroups(parentGroup)" :key="group.id" :to="urlFor(group)")
            v-list-item-title
              span {{group.name}}
              template(v-if='openCounts[group.id]')
                | &nbsp;
                span ({{openCounts[group.id]}})
      template(v-else)
        v-list-item(nav slim :to="urlFor(parentGroup)")
          template(v-slot:prepend)
            group-avatar.mr-4(:group="parentGroup")
          v-list-item-title
            span {{parentGroup.name}}
            template(v-if='openCounts[parentGroup.id]')
              | &nbsp;
              span ({{openCounts[parentGroup.id]}})

    v-list-item.sidebar__list-item-button--start-group(nav slim v-if="canStartGroups" to="/g/new")
      template(v-slot:prepend)
        common-icon(tile name="mdi-plus")
      v-list-item-title(v-t="'group_form.new_group'")

    v-divider.my-2
    v-list-item.sidebar__list-item-button--start-group(v-if="canStartDemo" @click="startOrFindDemo" lines="two")
      v-list-item-title(v-t="'templates.start_a_demo'")
      v-list-item-subtitle(v-t="'templates.play_with_an_example_group'")
      template(v-slot:append)
        common-icon(name="mdi-car-convertible")
    v-list-item(v-if="showHelp", :href="helpURL" target="_blank" lines="two")
      v-list-item-title(v-t="'sidebar.help_docs'")
      v-list-item-subtitle(v-t="'sidebar.a_detailed_guide_to_loomio'")
      template(v-slot:append)
        common-icon(name="mdi-book-open-page-variant")
    v-list-item(to="/explore" v-if="showExploreGroups")
      v-list-item-title(v-t="'sidebar.explore_groups'")
      template(v-slot:append)
        common-icon(name="mdi-map-search")
    v-list-item(v-if="showContact" @click="$router.replace('/contact')" lines="two")
      v-list-item-title(v-t="'user_dropdown.contact_support'")
      v-list-item-subtitle(v-t="'sidebar.talk_to_the_loomio_team'")
      template(v-slot:append)
        common-icon(name="mdi-face-agent")
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
