<script lang="js">
import PollEventDetails from '@/components/poll/event/details.vue';

export default {
  components: { PollEventDetails },
  props: {
    poll: Object
  }
};
</script>

<template lang="pug">
.poll-common-details-panel.pt-2
  v-list-subheader.ml-n4(v-t="'poll_common.details'" v-if='poll.outcome()')
  poll-common-details-meta(:poll="poll")
  poll-event-details(v-if="poll.pollType === 'event'" :poll="poll")
  formatted-text.poll-common-details-panel__details(:model="poll" field="details")
  link-previews(:model="poll")
  attachment-list(:attachments="poll.attachments")
</template>
