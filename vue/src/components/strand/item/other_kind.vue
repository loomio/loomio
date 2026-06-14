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
strand-item-headline(:event="event" :eventable="eventable")
</template>

<style>
.strand-other-kind .actor-link {

}

</style>
