<script lang="coffee">

export default
  props:
    poll: Object
</script>

<template lang="pug">
.poll-common-details-panel.pt-2
  v-subheader.ml-n4(v-t="'poll_common.details'" v-if='poll.outcome()')
  .poll-common-details-panel__started-by.text--secondary.mb-4
    span(v-t="{ path: 'poll_card.started_by', args: { name: poll.authorName() } }")
    mid-dot
    poll-common-closing-at(:poll='poll')
    mid-dot(v-if='poll.anonymous')
    span(v-if='poll.anonymous', md-colors="{color: 'primary-600', 'border-color': 'primary-600'}" v-t="'common.anonymous'")
  formatted-text.poll-common-details-panel__details(:model="poll" column="details")
  link-previews(:model="poll")
  attachment-list(:attachments="poll.attachments")
  document-list(:model='poll')
</template>
