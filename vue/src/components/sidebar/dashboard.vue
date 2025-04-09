<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Session        from '@/shared/services/session';
import Flash        from '@/shared/services/flash';
import Records        from '@/shared/services/records';
import PlausibleService        from '@/shared/services/plausible_service';
import AbilityService from '@/shared/services/ability_service';
import UrlFor from '@/mixins/url_for';
import InboxService   from '@/shared/services/inbox_service';

export default {
  mixins: [UrlFor],
  props: ['organizations', 'openCounts', 'unreadDirectThreadsCount'],

  computed: {
    canStartGroups() { return AbilityService.canStartGroups(); },
    canStartDemo() { return AppConfig.features.app.demos; },
    canViewPublicGroups() { return AbilityService.canViewPublicGroups(); },
    showExploreGroups() { return AppConfig.features.app.explore_public_groups; },
    showHelp() { return AppConfig.features.app.help_link; },
    helpURL() {
      const siteUrl = new URL(AppConfig.baseUrl);
      return `https://help.loomio.com/en/?utm_source=${siteUrl.host}`;
    },
    showContact() { return AppConfig.features.app.show_contact; },
    canStartDemo() { return AppConfig.features.app.demos; },
  },

  methods: {
    unreadThreadCount() {
      return InboxService.unreadCount();
    },

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
  }
}

</script>

<template lang="pug">
v-list.mb-0.pb-0(nav density="compact")
  //- v-list-item.sidebar__list-item-button--recent(
  //-   to="/dashboard"
  //-   :title="$t('dashboard_page.aria_label')")
  v-list-item(
    to="/inbox"
    :title="$t('sidebar.unread_threads', { count: unreadThreadCount() })")
  v-list-item.sidebar__list-item-button--private(
    to="/threads/direct"
  )
    v-list-item-title
      span(v-t="'sidebar.invite_only_threads'")
      span(v-if="unreadDirectThreadsCount > 0")
        space
        span ({{unreadDirectThreadsCount}})

  v-list-item(
    to="/tasks"
    :disabled="organizations.length == 0"
    :title="$t('tasks.tasks')")

v-list.mt-0.pb-0(nav density="compact")
  v-divider
  v-list-subheader Organizations
  v-list-item(v-for="group in organizations" :to="urlFor(group)")
    template(v-slot:prepend)
      group-avatar.mr-2(:group="group")
    v-list-item-title
      span {{group.name}}
      template(v-if='openCounts[group.id]')
        | &nbsp;
        span ({{openCounts[group.id]}})

  v-btn.sidebar__list-item-button--start-group(
    block
    variant="tonal"
    color="primary"
    v-if="canStartGroups" to="/g/new"
  )
    span(v-t="'sidebar.start_group'")

  v-divider.my-2
  v-list-item.sidebar__list-item-button--start-demo(v-if="canStartDemo" @click="startOrFindDemo" lines="two")
    v-list-item-title(v-t="'templates.start_a_demo'")
    v-list-item-subtitle(v-t="'templates.play_with_an_example_group'")
    template(v-slot:append)
      common-icon(name="mdi-car-convertible")

  v-list-item(v-if="showHelp", :href="helpURL" target="_blank" lines="two")
    v-list-item-title(v-t="'common.loomio_help'")
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
