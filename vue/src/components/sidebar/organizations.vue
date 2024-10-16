<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import AbilityService from '@/shared/services/ability_service';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [UrlFor],
  props: ['organizations', 'openCounts'],
  computed: {
    canStartGroups() { return AbilityService.canStartGroups(); },
  }
}

</script>

<template lang="pug">
v-list-subheader#organizations
  span(v-t="'common.organizations'")

v-list-item(v-for="group in organizations" nav slim :to="urlFor(group)")
  template(v-slot:prepend)
    group-avatar.mr-4(:group="group")
  v-list-item-title
    span {{group.name}}
    template(v-if='openCounts[group.id]')
      | &nbsp;
      span ({{openCounts[group.id]}})

v-list-item.sidebar__list-item-button--start-group(nav slim v-if="canStartGroups" to="/g/new")
  template(v-slot:prepend)
    common-icon(tile name="mdi-plus")
  v-list-item-title(v-t="'sidebar.start_group'")
</template>
