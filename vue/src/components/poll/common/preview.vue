<script lang="coffee">
import Session from '@/shared/services/session'

export default
  props:
    poll: Object
    displayGroupName: Boolean
  methods:
    showGroupName: ->
      @displayGroupName && @poll.groupId
</script>

<template lang="pug">
v-list-item.poll-common-preview(:to='urlFor(poll)')
  v-list-item-avatar
    poll-common-chart-preview(:poll='poll')
  v-list-item-content
    v-list-item-title
      | {{poll.title}}
      tags-display(:tags="poll.tags()")
    v-list-item-subtitle
      span(v-t="{ path: 'poll_common_collapsed.by_who', args: { name: poll.authorName() } }")
      space
      span ·
      space
      span(v-if='displayGroupName && poll.groupId')
        span {{ poll.group().name }}
        space
        span ·
        space
      poll-common-closing-at(:poll='poll' approximate)
</template>
<style lang="sass">
.poll-common-preview .v-avatar
  overflow: visible! important
</style>
