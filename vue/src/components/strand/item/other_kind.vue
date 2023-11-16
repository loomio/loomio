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
        polltype: this.$t(eventPollType(this.event)).toLowerCase()
      });
    }
  }
};
</script>

<template lang="pug">
.strand-other-kind
  //- | hi {{event.model().poll().title}}
  span.text--secondary(v-html='headline')
  mid-dot.text--secondary
  time-ago.text--secondary(:date='event.createdAt')
  formatted-text.thread-item__body(:model="eventable" column="statement")
</template>
