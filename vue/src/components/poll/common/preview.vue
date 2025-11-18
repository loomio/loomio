<script lang="js">
import LmoUrlService from '@/shared/services/lmo_url_service';

export default {
  props: {
    poll: Object,
    displayGroupName: Boolean,
    fullName: Boolean
  },
  computed: {
    link() { return LmoUrlService.discussionPoll(this.poll); },
    needsVote() { return this.poll.iCanVote() && !this.poll.iHaveVoted() }
  }
};
</script>

<template lang="pug">
v-list-item.poll-common-preview(:to='link')
  template(v-slot:prepend)
    poll-common-icon-panel.mr-2(:poll='poll' show-my-stance :size="36")
  v-list-item-title(:class="{'text-medium-emphasis': !needsVote, 'font-weight-medium': needsVote }")
    plain-text(:model="poll" field="title")
    tags-display.ml-1(:tags="poll.tags" :group="poll.group()" size="x-small")
  v-list-item-subtitle
    span(v-if='displayGroupName && poll.groupId')
      span(v-if="fullName") {{ poll.group().fullName }}
      span(v-if="!fullName") {{ poll.group().name }}
    template(v-else)
      span(v-t="{ path: 'poll_common_collapsed.by_who', args: { name: poll.authorName() } }")
    space
    span ·
    space
    poll-common-closing-at(:poll='poll' approximate)
</template>
<style lang="sass">
.poll-common-preview .v-avatar
  overflow: visible! important
.poll-common-preview .v-list-item-title
  white-space: wrap
</style>
