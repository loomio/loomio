<script lang="js">
import AppConfig         from '@/shared/services/app_config';
import Session           from '@/shared/services/session';
import Records           from '@/shared/services/records';
import EventBus          from '@/shared/services/event_bus';
import AbilityService    from '@/shared/services/ability_service';
import GroupService    from '@/shared/services/group_service';
import LmoUrlService     from '@/shared/services/lmo_url_service';
import { pickBy } from 'lodash-es';
import OldPlanBanner from '@/components/group/old_plan_banner';

export default
{
  components: { OldPlanBanner },

  data() {
    return {
      group: null,
      activeTab: '',
      groupFetchError: null
    };
  },

  created() {
    this.init();
    EventBus.$on('signedIn', this.init);
  },

  beforeDestroy() {
    EventBus.$off('signedIn', this.init);
  },

  watch: {
    '$route.params.key': 'init'
  },

  computed: {
    dockActions() {
      return pickBy(GroupService.actions(this.group), v => v.dock);
    },

    menuActions() {
      return pickBy(GroupService.actions(this.group), v => v.menu);
    },

    canEditGroup() {
      return AbilityService.canEditGroup(this.group);
    },

    tabs() {
      if (!this.group) { return; }
      let query = '';
      if (this.$route.query.subgroups) { query = '?subgroups='+this.$route.query.subgroups; }

      return [
        {id: 0, name: 'threads',   route: this.urlFor(this.group, null)+query},
        {id: 1, name: 'decisions', route: this.urlFor(this.group, 'polls')+query},
        {id: 2, name: 'members',   route: this.urlFor(this.group, 'members')+query},
        {id: 4, name: 'files',     route: this.urlFor(this.group, 'files')+query},
        {id: 5, name: 'subgroups',  route: this.urlFor(this.group, 'subgroups')+query}
        // {id: 6, name: 'settings',  route: @urlFor(@group, 'settings')}
      ].filter(obj => !((obj.name === "subgroups") && this.group.parentId));
    }
  },

  methods: {
    init() {
      Records.groups.findOrFetch(this.$route.params.key)
      .then(group => {
        this.group = group;
        if (this.group.newHost) { window.location.host = this.group.newHost; }
    }).catch(error => {
        EventBus.$emit('pageError', error);
        if ((error.status === 403) && !Session.isSignedIn()) { EventBus.$emit('openAuthModal'); }
      });
    },

    openGroupSettingsModal() {
      if (!this.canEditGroup) { return null; }
      EventBus.$emit('openModal', {
        component: 'GroupForm',
        props: {
          group: this.group
        }
      });
    }
  }
};

</script>

<template>

<v-main>
  <loading v-if="!group"></loading>
  <v-container class="group-page max-width-1024 px-2 px-sm-4" v-if="group">
    <div style="position: relative">
      <v-img :src="group.coverUrl" style="border-radius: 8px" max-height="256" eager="eager"></v-img>
      <v-img class="ma-2 d-none d-sm-block rounded" v-if="group.logoUrl" :src="group.logoUrl" style="border-radius: 8px; position: absolute; bottom: 0" height="96" width="96" eager="eager"></v-img>
      <v-img class="ma-2 d-sm-none rounded" v-if="group.logoUrl" :src="group.logoUrl" style="border-radius: 8px; position: absolute; bottom: 0" height="48" width="48" eager="eager"></v-img>
    </div>
    <h1 class="display-1 my-4" tabindex="-1" v-observe-visibility="{callback: titleVisible}"><span v-if="group && group.parentId">
        <router-link :to="urlFor(group.parent())">{{group.parent().name}}</router-link>
        <space></space><span class="text--secondary text--lighten-1">></span>
        <space></space></span><span class="group-page__name mr-4">{{group.name}}</span></h1>
    <old-plan-banner :group="group"></old-plan-banner>
    <trial-banner :group="group"></trial-banner>
    <formatted-text class="group-page__description" v-if="group" :model="group" column="description"></formatted-text>
    <action-dock :model="group" :actions="dockActions" menu-icon="mdi-cog" :menu-actions="menuActions"></action-dock>
    <join-group-button :group="group"></join-group-button>
    <link-previews :model="group"></link-previews>
    <document-list :model="group"></document-list>
    <attachment-list :attachments="group.attachments"></attachment-list>
    <v-divider class="mt-4"></v-divider>
    <v-tabs v-model="activeTab" background-color="transparent" center-active="center-active" grow="grow">
      <v-tab v-for="tab of tabs" :key="tab.id" :to="tab.route" :class="'group-page-' + tab.name + '-tab' "><span v-t="'group_page.'+tab.name"></span></v-tab>
    </v-tabs>
    <router-view></router-view>
  </v-container>
</v-main>
</template>

<style lang="sass">
.group-page-tabs
	.v-tab
		&:not(.v-tab--active)
			color: hsla(0,0%,100%,.85) !important

</style>
