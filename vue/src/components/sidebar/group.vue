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
//- v-divider.my-2#sidebar-current-organization
//- v-list-subheader Current organization
//- v-list-item(nav slim to="/dashboard")
//-   template(v-slot:prepend)
//-     common-icon(name="mdi-chevron-left")
//-   v-list-item-title Dashboard

v-list(nav density="compact")
  v-list-item(nav slim :to="urlFor(organization)")
    template(v-slot:prepend)
      group-avatar.mr-2(:size="24" :group="organization")
    v-list-item-title {{organization.name}}
    v-list-item-subtitle(v-if='openCounts[organization.id]')
      | {{openCounts[organization.id]}} unread

  template(v-if="mine.length")
    v-divider.my-3
    v-list-subheader
      span(v-t="'group_page.my_subgroups'")

    v-list-item(v-for="group in mine" nav slim :to="urlFor(group)")
      v-list-item-title
        span {{group.name}}
        template(v-if='openCounts[group.id]')
          | &nbsp;
          span ({{openCounts[group.id]}})

  template(v-if="more.length")
    v-divider.my-3
    v-list-subheader
      span(v-if="mine.length" v-t="'group_page.more_subgroups'")
      span(v-else v-t="'group_page.subgroups'")

    v-list-item(v-for="group in more" nav slim :to="urlFor(group)")
      v-list-item-title
        span {{group.name}}
        template(v-if='openCounts[group.id]')
          | &nbsp;
          span ({{openCounts[group.id]}})

  v-btn.sidebar__list-item-button--start-group(
    block
    variant="tonal"
    color="primary"
    v-if="canStartSubgroup"
    :to="'/g/new?parent_id='+organization.id")
    span(v-t="'group_form.new_subgroup'")
</template>
