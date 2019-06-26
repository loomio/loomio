<script lang="coffee">
import fromNow        from '@/mixins/from_now'
import exactDate      from '@/mixins/exact_date'

export default
  mixins: [fromNow, exactDate]
  props:
    poll: Object
  methods:
    time: ->
      key = if @poll.isActive() then 'closingAt' else 'closedAt'
      @poll[key]

    translationKey: ->
      if @poll.isActive()
        'common.closing_in'
      else
        'common.closed_ago'
</script>

<template>
<abbr class="closing-in timeago--inline">
  <span v-t="{ path: translationKey(), args: { time: fromNow(time()) } }" :title="exactDate(time())"></span>
</abbr>
</template>
