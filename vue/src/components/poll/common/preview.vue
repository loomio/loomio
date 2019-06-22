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
v-list-item.poll-common-preview(:to='urlFor(poll)')
  v-list-item-avatar
    poll-common-chart-preview(:poll='poll')
  v-list-item-content
    v-list-item-title {{poll.title}}
    v-list-item-subtitle
      span(v-if='showGroupName()') {{ poll.group().fullName }}
      span(v-if='!showGroupName()', v-t="{ path: 'poll_common_collapsed.by_who', args: { name: poll.authorName() } }")
      span ·
      poll-common-closing-at(:poll='poll')
</template>
