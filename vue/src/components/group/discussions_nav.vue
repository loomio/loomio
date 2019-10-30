<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { filter, debounce, truncate, first, last, some, drop, omit} from 'lodash'

export default
  data: ->
    group: null

  created: ->
    Records.groups.findOrFetch(@$route.params.key).then (group) =>
      @group = group

    EventBus.$on 'currentComponent', (options) =>
      @group = options.group
      return unless @group

  computed:
    groupTags: ->
      @group && @group.parentOrSelf().tagNames || []

    unreadCount: ->
      filter(@discussions, (discussion) -> discussion.isUnread()).length


</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(:permanent="$vuetify.breakpoint.mdAndUp" width="230px" app fixed right clipped color="transparent" floating)
  ul
    li
      router-link(:to="{query: {t: 'open'}}" v-t="'discussions_panel.open'")
    li
      router-link(:to="{query: {t: 'unread'}}" v-t="{ path: 'discussions_panel.unread', args: { count: unreadCount }}")
    li
      router-link(:to="{query: {t: 'closed'}}" v-t="'discussions_panel.closed'")
    li(v-for="tag in groupTags" :key="tag")
      router-link(:to="{query: {t: tag}}") {{tag}}

</template>

<style lang="sass">
</style>
