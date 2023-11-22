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

<template>

<div class="strand-other-kind"><span class="text--secondary" v-html="headline"></span>
  <mid-dot class="text--secondary"></mid-dot>
  <time-ago class="text--secondary" :date="event.createdAt"></time-ago>
  <formatted-text class="thread-item__body" :model="eventable" column="statement"></formatted-text>
</div>
</template>
