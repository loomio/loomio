<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { keys, values, omit} from 'lodash'

export default
  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
    filter: 'all'
    subgroups: 'mine'
    pollTypes: AppConfig.pollTypes

  methods:
    selectFilter: (pair) ->
      name = keys(pair)[0]
      value  = values(pair)[0]

      params = omit(@$route.query, ['t', 'status', 'poll_type'])

      if value == "all"
        @$router.replace(query: params)
      else
        @$router.replace(query: Object.assign({}, params, {"#{name}": value}))

      @filter = value

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(:permanent="$vuetify.breakpoint.mdAndUp" width="230px" app fixed right clipped color="transparent" floating)
  ul.pl-2(v-model="filter" active-class="accent--text")
    li(label outlined value="all" @click="selectFilter({status: 'all'})" v-t="'polls_panel.all'")
    li(label outlined value="active" @click="selectFilter({status: 'active'})" v-t="'polls_panel.open'")
    li(label outlined value="closed" @click="selectFilter({status: 'closed'})" v-t="'polls_panel.closed'")
    li(v-for="pollType in pollTypes" :key="pollType" :value="pollType" @click="selectFilter({poll_type: pollType})" v-t="'poll_types.'+pollType")
</template>
<style lang="sass">
</style>
