<style lang="scss">
</style>

<script lang="coffee">
fromNow        = require 'src/mixins/from_now'
exactDate      = require 'src/mixins/exact_date'

module.exports =
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
