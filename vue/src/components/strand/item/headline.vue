<script lang="js">
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext';
import LmoUrlService  from '@/shared/services/lmo_url_service';

export default {
  props: {
    event: Object,
    eventable: Object,
    collapsed: Boolean,
    dateTime: Date,
    focused: Boolean,
    unread: Boolean
  },

  computed: {
    isDelegate() {
      const actor = this.event.actor();
      const group = this.eventable.group();
      return actor && group && actor.delegates && actor.delegates[group.id]
    },
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
          polltype: this.event.isPollEvent() ? this.$t(eventPollType(this.event)).toLowerCase() : null
        });
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
    slot(name="headline")
      span.strand-item__headline.text-medium-emphasis(v-html='headline')
    space(v-if="isDelegate")
    v-chip(v-if="isDelegate" size="x-small" variant="tonal" label :title="$t('members_panel.delegate_popover')")
      span(v-t="'members_panel.delegate'")
    mid-dot.text-medium-emphasis
    router-link.text-medium-emphasis.text-body-2(:to='link')
      time-ago(:date='datetime')
    v-badge(v-if="unread" variant="tonal" color="info" inline location="right" :content="$t('thread_item.new')")
    mid-dot(v-if="event.pinned")
    common-icon.text--disabled(v-if="event.pinned" name="mdi-pin-outline")

</template>
<style lang="sass">
.strand-item__headline
  strong
    font-weight: 400
  .actor-link
    color: inherit
.text-medium-emphasis
  .actor-link
    color: inherit
</style>
