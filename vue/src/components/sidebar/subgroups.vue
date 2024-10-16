<script lang="js">
import UrlFor from '@/mixins/url_for';
import Session        from '@/shared/services/session';
import WatchRecords from '@/mixins/watch_records';
import AbilityService from '@/shared/services/ability_service';

export default {
  mixins: [UrlFor, WatchRecords],
  props: ['organization', 'openCounts'],

  data() {
    return {
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
v-divider.my-2#current-organization
v-list-subheader Current organization

v-list-item(nav slim :to="urlFor(organization)")
  template(v-slot:prepend)
    group-avatar.mr-4(:group="organization")
  v-list-item-title
    span {{organization.name}}
    template(v-if='openCounts[organization.id]')
      | &nbsp;
      span ({{openCounts[organization.id]}})

template(v-if="mine.length")
  v-list-subheader
    span(v-t="'group_page.my_subgroups'")

  v-list-item(v-for="group in mine" nav slim :to="urlFor(group)")
    v-list-item-title
      span {{group.name}}
      template(v-if='openCounts[group.id]')
        | &nbsp;
        span ({{openCounts[group.id]}})

template(v-if="more.length")
  v-list-subheader
    span(v-if="mine.length" v-t="'group_page.more_subgroups'")
    span(v-else v-t="'group_page.subgroups'")

  v-list-item(v-for="group in more" nav slim :to="urlFor(group)")
    v-list-item-title
      span {{group.name}}
      template(v-if='openCounts[group.id]')
        | &nbsp;
        span ({{openCounts[group.id]}})

v-list-item.sidebar__list-item-button--start-group(
  nav slim
  v-if="canStartSubgroup"
  :to="'/g/new?parent_id='+organization.id")

  template(v-slot:prepend)
    common-icon(tile name="mdi-plus")
  v-list-item-title(v-t="'group_form.new_subgroup'")
</template>
