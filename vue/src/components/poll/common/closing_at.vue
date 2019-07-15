<script lang="coffee">
import { exact } from '@/shared/helpers/format_time'

export default
  props:
    poll: Object

  methods:
    exact: exact
    
  computed:
    time: ->
      key = if @poll.isActive() then 'closingAt' else 'closedAt'
      @poll[key]

    translationKey: ->
      if @poll.isActive()
        'common.closing_in'
      else
        'common.closed_ago'
</script>

<template lang="pug">
abbr.closing-in.timeago--inline
  span(v-t="{ path: translationKey, args: { time: exact(time) } }" :title="exact(time)")
</template>
