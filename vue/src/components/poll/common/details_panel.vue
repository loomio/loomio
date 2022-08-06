<script lang="coffee">

export default
  props:
    poll: Object
</script>

<template lang="pug">
.poll-common-details-panel.pt-2
  v-subheader.ml-n4(v-t="'poll_common.details'" v-if='poll.outcome()')
  .poll-common-details-panel__started-by.text--secondary.mb-4
    span(v-t="{ path: 'poll_card.poll_type_by_name', args: { name: poll.authorName(), poll_type: poll.translatedPollTypeCaps() } }")
    mid-dot
    poll-common-closing-at(:poll='poll')
  formatted-text.poll-common-details-panel__details(:model="poll" column="details")
  link-previews(:model="poll")
  attachment-list(:attachments="poll.attachments")
  document-list(:model='poll')
</template>
