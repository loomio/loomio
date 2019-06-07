<script lang="coffee">
import Session from '@/shared/services/session'
import UrlFor  from '@/mixins/url_for'

export default
  mixins: [UrlFor]
  props:
    poll: Object
    displayGroupName: Boolean
  methods:
    showGroupName: ->
      @displayGroupName && @poll.group()
</script>

<template lang="pug">
v-list-tile.poll-common-preview(:to='urlFor(poll)')
  v-list-tile-avatar
    poll-common-chart-preview(:poll='poll')
  v-list-tile-content
    v-list-tile-title {{poll.title}}
    v-list-tile-sub-title
      span(v-if='showGroupName()') {{ poll.group().fullName }}
      span(v-if='!showGroupName()', v-t="{ path: 'poll_common_collapsed.by_who', args: { name: poll.authorName() } }")
      span ·
      poll-common-closing-at(:poll='poll')
</template>
