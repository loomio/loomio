<script lang="js">
import Session           from '@/shared/services/session';
import Records           from '@/shared/services/records';
import EventBus          from '@/shared/services/event_bus';
import AbilityService    from '@/shared/services/ability_service';
import GroupService    from '@/shared/services/group_service';
import { pickBy } from 'lodash-es';
import UrlFor from '@/mixins/url_for';
import FormatDate from '@/mixins/format_date';

export default
{
  mixins: [UrlFor, FormatDate],
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

      return [
        {id: 0, name: 'discussions',   route: this.urlFor(this.group, null)+query},
        {id: 1, name: 'polls',     route: this.urlFor(this.group, 'polls')+query},
        {id: 2, name: 'members',   route: this.urlFor(this.group, 'members')+query},
        {id: 4, name: 'files',     route: this.urlFor(this.group, 'files')+query},
      ].filter(obj => !((obj.name === "subgroups") && this.group.parentId));
    }
  },

  methods: {
    init() {
      Records.groups.findOrFetch(this.$route.params.key).then(group => {
        this.group = group;
        if (this.group.newHost) { window.location.host = this.group.newHost; }
      }).catch(error => {
        EventBus.$emit('pageError', error);
        if ((error.status === 403) && !Session.isSignedIn()) { EventBus.$emit('openAuthModal'); }
      });
    }
  }
};

</script>

<template lang="pug">
v-main
  loading(v-if="!group")
  v-container.group-page.max-width-1024.px-2.px-sm-4(v-if="group")
    div(style="position: relative")
      v-img(
        :src="group.coverUrl"
        style="border-radius: 8px"
        max-height="256"
        cover
        eager)

      //v-img.ma-2.d-none.d-sm-block.rounded(
      //  v-if="group.logoUrl"
      //  :src="group.logoUrl"
      //  style="border-radius: 8px; position: absolute; bottom: 0"
      //  height="96"
      //  width="96"
      //  eager)
      //v-img.ma-2.d-sm-none.rounded(
      //  v-if="group.logoUrl"
      //  :src="group.logoUrl"
      //  style="border-radius: 8px; position: absolute; bottom: 0"
      //  height="48"
      //  width="48"
      //  eager)
    h1.text-headline-large.my-4(tabindex="-1" v-intersect="{handler: titleVisible}")
      span(v-if="group && group.parentId")
        router-link(:to="urlFor(group.parent())")
          plain-text(:model="group.parent()" field="name")
        space
        span.text-medium-emphasis.text--lighten-1 &gt;
        space
      plain-text.group-page__name.mr-4(:model="group" field="name")
    plan-banner(:group="group")
    formatted-text.group-page__description(
      v-if="group"
      :model="group"
      field="description")
    link-previews(:model="group")
    action-dock(
      :model='group'
      :actions='dockActions'
      menu-icon='mdi-cog'
      :menu-actions='menuActions')
    join-group-button(:group='group')
    document-list(:model='group')
    attachment-list(:attachments="group.attachments")
    v-divider.mt-4
    v-tabs(
      color="primary"
      v-model="activeTab"
      background-color="transparent"
      center-active
      grow
    )
      v-tab(
        v-for="tab of tabs"
        :key="tab.id"
        :to="tab.route"
        :class="'group-page-' + tab.name + '-tab' "
      )
        //- common-icon(name="mdi-comment-multiple")
        span(v-t="'group_page.'+tab.name")
    router-view
</template>

<style lang="css">
.action-dock__button--email_group {
  text-transform: none !important;
}
</style>
