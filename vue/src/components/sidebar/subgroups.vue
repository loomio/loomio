<script lang="js">
import UrlFor from '@/mixins/url_for';
import Session        from '@/shared/services/session';
import WatchRecords from '@/mixins/watch_records';
import AbilityService from '@/shared/services/ability_service';
import { mdiPlus } from '@mdi/js';

export default {
  mixins: [UrlFor, WatchRecords],
  props: ['organization', 'openCounts'],

  data() {
    return {
      mdiPlus,
      mine: [],
      more: [],
      canStartSubgroup: false,
    }
  },

  created() {
    this.watchRecords({
      collections: ['groups', 'memberships'],
      query: store => {
        this.mine = this.organization.subgroups().filter(g => !g.archivedAt && g.membershipFor(Session.user()));
        this.more = this.organization.subgroups().filter(g => AbilityService.canViewGroup(g) && !g.membershipFor(Session.user()));
        this.canStartSubgroup = AbilityService.canCreateSubgroups(this.organization);
      }
    });
  },

}

</script>

<template lang="pug">
v-list.ma-0.pa-0.pb-2(v-if="mine.length || more.length || canStartSubgroup" nav density="compact" :lines="false")
  template(v-if="mine.length")
    v-list-subheader
      span(v-t="'group_page.my_subgroups'")

    v-list-item(v-for="group in mine" nav slim :to="urlFor(group)")
      v-list-item-title
        plain-text(:model="group" field="name")
        template(v-if='openCounts[group.id]')
          | &nbsp;
          span ({{openCounts[group.id]}})

  template(v-if="more.length")
    v-list-subheader
      span(v-if="mine.length" v-t="'group_page.more_subgroups'")
      span(v-else v-t="'group_page.subgroups'")

    v-list-item(v-for="group in more" nav slim :to="urlFor(group)")
      v-list-item-title
        plain-text(:model="group" field="name")
        template(v-if='openCounts[group.id]')
          | &nbsp;
          span ({{openCounts[group.id]}})

  v-btn.sidebar-start-subgroup.mb-2(
    size="small"
    block
    variant="tonal"
    color="primary"
    v-if="canStartSubgroup"
    :to="'/g/new?parent_id='+organization.id"
  )
    span(v-t="'group_form.new_subgroup'")

</template>
