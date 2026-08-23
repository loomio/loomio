<script lang="js">
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext';
import LmoUrlService  from '@/shared/services/lmo_url_service';

export default {
  props: {
    topic_item: Object,
    itemable: Object,
    collapsed: Boolean,
    dateTime: Date,
    focused: Boolean,
    unread: Boolean
  },

  computed: {
    isDelegate() {
      const actor = this.topic_item.actor();
      const group = this.itemable.group();
      return actor && group && actor.delegates && actor.delegates[group.id]
    },
    datetime() { return this.dateTime || this.itemable.castAt || this.itemable.createdAt; },
    headline() {
      const actor = this.topic_item.actor();
      return this.$t(eventHeadline(this.topic_item, true ), { // useNesting
        author:   actor.nameWithTitle(this.itemable.group()),
        username: actor.username,
        key:      this.topic_item.model().key,
        title:    eventTitle(this.topic_item),
        polltype: this.topic_item.isPollTopicItem() ? this.$t(eventPollType(this.topic_item)).toLowerCase() : null
      });
    },

    link() {
      return LmoUrlService.topic_item(this.topic_item);
    }
  }
};

</script>

<template lang="pug">
h3.strand-item__headline.thread-item__title.text-body-medium.pb-1(tabindex="-1")
  div.d-flex.align-center
    span.strand-item__headline.text-medium-emphasis.text-decoration-none(v-html='headline')
    space(v-if="isDelegate")
    v-chip(v-if="isDelegate" size="x-small" variant="tonal" label :title="$t('members_panel.delegate_popover')")
      span(v-t="'members_panel.delegate'")
    mid-dot.text-medium-emphasis
    router-link.actor-link(:to='link')
      time-ago.text-medium-emphasis(:date='datetime')
    v-badge(v-if="unread" variant="tonal" color="info" inline location="right" :content="$t('thread_item.new')")
    mid-dot(v-if="topic_item.pinned")
    common-icon.text--disabled(v-if="topic_item.pinned" name="mdi-pin-outline")

</template>
<style>
.strand-item__headline strong {
  font-weight: 400;
}
.strand-item__headline .actor-link {
  text-decoration: none;
  color: inherit;
}
.strand-item__headline .actor-link:hover {
  text-decoration: underline;
}
</style>
