<script lang="js">
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import Records from '@/shared/services/records';

export default {
  props: {
    event: Object,
    eventable: Object,
    collapsed: Boolean,
    dateTime: Date
  },

  computed: {
    datetime() { return this.dateTime || this.eventable.castAt || this.eventable.createdAt; },
    headline() {
      const actor = this.event.actor();
      if ((this.event.kind === 'new_comment') && this.collapsed && (this.event.descendantCount > 0)) {
        return this.$t('reactions_display.name_and_count_more', {name: actor.nameWithTitle(this.eventable.group()), count: this.event.descendantCount});
      } else {
        return this.$t(eventHeadline(this.event, true ), { // useNesting
          author:   actor.nameWithTitle(this.eventable.group()),
          username: actor.username,
          key:      this.event.model().key,
          title:    eventTitle(this.event),
          polltype: this.$t(eventPollType(this.event)).toLowerCase()
        }
        );
      }
    },

    link() {
      return LmoUrlService.event(this.event);
    }
  }
};

</script>

<template lang="pug">
h3.strand-item__headline.thread-item__title.text-body-2.pb-1(tabindex="-1")
  div.d-flex.align-center
    //- common-icon(v-if="event.pinned" name="mdi-pin")
    slot(name="headline")
      span.strand-item__headline.text--secondary(v-html='headline')
    mid-dot.text--secondary
    router-link.text--secondary.text-body-2(:to='link')
      time-ago(:date='datetime')
    mid-dot(v-if="event.pinned")
    common-icon.text--disabled(v-if="event.pinned" name="mdi-pin-outline")

</template>
<style lang="sass">
.strand-item__headline
  strong
    font-weight: 400
  .actor-link
    color: inherit
.text--secondary
  .actor-link
    color: inherit

</style>
