<script lang="coffee">
import Records        from '@/shared/services/records'
export default
  props: {}
  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
</script>
<template lang="pug">
v-card
  v-tabs(fixed-tabs)
    v-tab(:to="urlFor(group, 'members')" v-t="'members_panel.directory'")
    v-tab(:to="urlFor(group, 'members/invitations')" v-t="'members_panel.invitations'")
    v-tab(:to="urlFor(group, 'members/requests')" v-t="'members_panel.requests'")

  router-view
</template>
