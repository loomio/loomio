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

<template>

<v-list-item class="poll-common-preview" :to="link">
  <v-list-item-avatar>
    <poll-common-icon-panel :poll="poll" show-my-stance="show-my-stance"></poll-common-icon-panel>
  </v-list-item-avatar>
  <v-list-item-content>
    <v-list-item-title><span>{{poll.title}}</span>
      <tags-display class="ml-1" :tags="poll.tags" :group="poll.group()" smaller="smaller"></tags-display>
    </v-list-item-title>
    <v-list-item-subtitle><span v-t="{ path: 'poll_common_collapsed.by_who', args: { name: poll.authorName() } }"></span>
      <space></space><span>·</span>
      <space></space><span v-if="displayGroupName && poll.groupId"><span>{{ poll.group().name }}</span>
        <space></space><span>·</span>
        <space></space></span>
      <poll-common-closing-at :poll="poll" approximate="approximate"></poll-common-closing-at>
    </v-list-item-subtitle>
  </v-list-item-content>
</v-list-item>
</template>
<style lang="sass">
.poll-common-preview .v-avatar
  overflow: visible! important
</style>
