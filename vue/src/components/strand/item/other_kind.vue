<script lang="js">
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext';
import Records        from '@/shared/services/records';

export default {
  props: {
    event: Object,
    eventable: Object
  },

  computed: {
    headline() {
      const actor = this.event.actor();
      return this.$t(eventHeadline(this.event, true ), { // useNesting
        author:   actor.nameWithTitle(this.eventable.group()),
        username: actor.username,
        key:      this.event.model().key,
        title:    eventTitle(this.event),
        polltype: this.event.isPollEvent() ? this.$t(eventPollType(this.event)).toLowerCase() : null
      });
    }
  }
};
</script>

<template lang="pug">
.strand-other-kind.text-body-medium
  span.text-medium-emphasis(v-html='headline')
  mid-dot.text-medium-emphasis
  time-ago.text-medium-emphasis(:date='event.createdAt')
  //formatted-text.thread-item__body(:model="eventable" field="statement")
</template>
