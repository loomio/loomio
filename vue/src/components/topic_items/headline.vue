<script lang="js">
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import ItemTags from '@/components/tags/item_tags.vue';
import { useI18n } from 'vue-i18n';

export default {
  components: { ItemTags },
  setup() {
    const { t } = useI18n();
    return { t };
  },
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
h3.topic-item__headline.topic-item__title.text-body-medium.pb-1(tabindex="-1")
  .d-flex.flex-wrap.align-center.ga-1
    .d-flex.flex-wrap.align-center
      span.topic-item__headline.text-medium-emphasis.text-decoration-none(v-html='headline')
      space(v-if="isDelegate")
      v-chip(v-if="isDelegate" size="x-small" variant="tonal" label :title="$t('members_panel.delegate_popover')")
        span {{ t('members_panel.delegate') }}
      mid-dot.text-medium-emphasis
      router-link.actor-link(:to='link')
        time-ago.text-medium-emphasis(:date='datetime')
      v-badge(v-if="unread" variant="tonal" color="info" inline location="right" :content="$t('thread_item.new')")
    item-tags.ml-auto(:topic-item="topic_item")

</template>
<style>
.topic-item__headline strong {
  font-weight: 400;
}
.topic-item__headline .actor-link {
  text-decoration: none;
  color: inherit;
}
.topic-item__headline .actor-link:hover {
  text-decoration: underline;
}
</style>
