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
v-navigation-drawer.lmo-no-print.discussions-nav(:permanent="$vuetify.breakpoint.mdAndUp" width="230px" app right clipped color="transparent" floating )
  v-card.pa-4.ma-4
    | welcome to your new group!

  v-subheader Filters
  ul
    li
      router-link(:to="{query: {t: 'open'}}" v-t="'discussions_panel.open'")
    li
      router-link(:to="{query: {t: 'unread'}}" v-t="{ path: 'discussions_panel.unread', args: { count: unreadCount }}")
    li
      router-link(:to="{query: {t: 'subscribed'}}" v-t="'change_volume_form.simple.loud'")
    li
      router-link(:to="{query: {t: 'closed'}}" v-t="'discussions_panel.closed'")
  v-subheader Tags
  ul
    li(v-for="tag in groupTags" :key="tag")
      router-link(:to="{query: {t: tag}}") {{tag}}

  v-subheader Subgroups
  ul
    li(v-for="tag in groupTags" :key="tag")
      router-link(:to="{query: {t: tag}}") {{tag}}

</template>

<style lang="sass">
</style>
