<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { keys, values, omit} from 'lodash'

export default
  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
    pollTypes: AppConfig.pollTypes
</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(:permanent="$vuetify.breakpoint.mdAndUp" width="230px" app right clipped color="transparent" floating)
  v-subheader Filters
  ul
    li
      router-link(:to="{query: {status: 'all' }}") Admins
    li
      router-link(:to="{query: {status: 'active'}}") Members
    li
      router-link(:to="{query: {status: 'closed'}}") Invited
    li
      router-link(:to="{query: {status: 'closed'}}") Requests

  v-subheader Poll type
  ul
    li(v-for="pollType in pollTypes" :key="pollType")
      router-link(:to="{query: {poll_type: pollType}}" v-t="'poll_types.'+pollType")
</template>
<style lang="sass">
</style>
