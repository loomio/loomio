<script lang="coffee">
import { exact, approximate } from '@/shared/helpers/format_time'

export default
  props:
    poll: Object
    approximate: Boolean

  methods:
    exact: exact
    timeMethod: ->
      if @approximate
        approximate(@time)
      else
        exact(@time)

  computed:
    time: ->
      key = if @poll.isActive() then 'closingAt' else 'closedAt'
      @poll[key]

    translationKey: ->
      if @poll.isActive()
        'common.closing_in'
      else
        'common.closed_ago'

    color: ->
      if @poll.isActive()
        'accent'
      else
        'warning'

</script>

<template lang="pug">
v-chip(small outlined :color="color")
  abbr.closing-in.timeago--inline
    span(v-t="{ path: translationKey, args: { time: timeMethod(time) } }" :title="exact(time)")
</template>
