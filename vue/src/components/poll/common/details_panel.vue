<script lang="coffee">

export default
  props:
    poll: Object
</script>

<template lang="pug">
.poll-common-details-panel
  v-subheader(v-t="'poll_common.details'" v-if='poll.outcome()')
  .poll-common-details-panel__started-by
    span(v-t="{ path: 'poll_card.started_by', args: { name: poll.authorName() } }")
    span(aria-hidden='true') ·
    poll-common-closing-at(:poll='poll')
    span(v-if='poll.anonymous') ·
    span(v-if='poll.anonymous', md-colors="{color: 'primary-600', 'border-color': 'primary-600'}" v-t="'common.anonymous'")
  formatted-text.poll-common-details-panel__details(:model="poll" column="details")
  attachment-list(:attachments="poll.attachments")
  document-list(:model='poll' skip-fetch)
</template>
