<script lang="js">

export default
  ({
    props: {
      poll: Object
    }
  });
</script>

<template>

<div class="poll-common-details-panel pt-2">
  <v-subheader class="ml-n4" v-t="'poll_common.details'" v-if="poll.outcome()"></v-subheader>
  <div class="poll-common-details-panel__started-by text--secondary mb-4"><span v-t="{ path: 'poll_card.poll_type_by_name', args: { name: poll.authorName(), poll_type: poll.translatedPollTypeCaps() } }"></span>
    <mid-dot></mid-dot>
    <poll-common-closing-at :poll="poll"></poll-common-closing-at>
  </div>
  <formatted-text class="poll-common-details-panel__details" :model="poll" column="details"></formatted-text>
  <link-previews :model="poll"></link-previews>
  <attachment-list :attachments="poll.attachments"></attachment-list>
  <document-list :model="poll"></document-list>
</div>
</template>
