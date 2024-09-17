<script lang="js">
import Session from '@/shared/services/session';
import TemplateBadge from '@/components/poll/common/template_badge';
import LmoUrlService from '@/shared/services/lmo_url_service';

export default {
  components: {TemplateBadge},
  props: {
    poll: Object,
    displayGroupName: Boolean
  },
  methods: {
    showGroupName() {
      return this.displayGroupName && this.poll.groupId;
    }
  },
  computed: {
    link() { return LmoUrlService.discussionPoll(this.poll); }
  }
};
</script>

<template lang="pug">
v-list-item.poll-common-preview(:to='link')
  template(v-slot:prepend)
    poll-common-icon-panel.mr-2(:poll='poll' show-my-stance size="36")
  v-list-item-title
    span {{poll.title}}
    tags-display.ml-1(:tags="poll.tags" :group="poll.group()" size="x-small")
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
