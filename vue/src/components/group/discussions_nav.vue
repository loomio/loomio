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

  methods:
    selectFilter: (filter) ->
      params = if filter == "open"
        omit @$route.query, ['t']
      else
        Object.assign({}, @$route.query, {t: filter})

      @$router.replace(query: params)

      @filter = filter

  computed:
    tags: ->
      intersection([@filter], @groupTags)

    groupTags: ->
      @group && @group.parentOrSelf().tagNames || []

    unreadCount: ->
      filter(@discussions, (discussion) -> discussion.isUnread()).length


</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(:permanent="$vuetify.breakpoint.mdAndUp" width="230px" app fixed right clipped color="transparent" floating)
  ul
    li(label outlined value="open" @click="selectFilter('open')")
      span(v-t="'discussions_panel.open'")
    li(label outlined value="unread" @click="selectFilter('unread')")
      span(v-t="{ path: 'discussions_panel.unread', args: { count: unreadCount }}")
    li(label outlined value="closed" @click="selectFilter('closed')")
      span(v-t="'discussions_panel.closed'")
  ul
    li(v-for="tag in groupTags" :key="tag" :value="tag" @click="selectFilter(tag)" outlined) {{tag}}

</template>

<style lang="sass">
</style>
