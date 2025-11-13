<script setup lang="js">
import { computed } from 'vue';
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { useI18n } from 'vue-i18n';

const props = defineProps({
  event: Object,
  eventable: Object,
  collapsed: Boolean,
  dateTime: Date,
  focused: Boolean,
  unread: Boolean
});

const { t } = useI18n();

const isDelegate = computed(() => {
  const actor = props.event.actor();
  const group = props.eventable.group();
  return actor && group && actor.delegates && actor.delegates[group.id];
});

const datetime = computed(() => {
  return props.dateTime || props.eventable.castAt || props.eventable.createdAt;
});

const headline = computed(() => {
  const actor = props.event.actor();
  if ((props.event.kind === 'new_comment') && props.collapsed && (props.event.descendantCount > 0)) {
    return t('reactions_display.name_and_count_more', {
      name: actor.nameWithTitle(props.eventable.group()),
      count: props.event.descendantCount
    });
  } else {
    return t(eventHeadline(props.event, true), { // useNesting
      author: actor.nameWithTitle(props.eventable.group()),
      username: actor.username,
      key: props.event.model().key,
      title: eventTitle(props.event),
      polltype: props.event.isPollEvent() ? t(eventPollType(props.event)).toLowerCase() : null
    });
  }
});

const link = computed(() => {
  return LmoUrlService.event(props.event);
});
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