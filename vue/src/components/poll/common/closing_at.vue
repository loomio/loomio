<script lang="coffee">
import { differenceInHours } from 'date-fns'
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
        if differenceInHours(@poll.closingAt, new Date) < 48
          'warning'
        else
          ''
      else
        'error'

    styles: ->
      if @color
        {color: 'var(--v-'+@color+'-base)'}
      else
        {}

</script>

<template lang="pug">
span(:style="styles")
  abbr.closing-in.timeago--inline(v-if="poll.closingAt")
    span(v-t="{ path: translationKey, args: { time: timeMethod(time) } }" :title="exact(time)")
  span(v-else v-t="'poll_common_wip_field.past_tense'")
</template>
