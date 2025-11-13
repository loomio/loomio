<script setup lang="js">
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext';
import Records from '@/shared/services/records';

const props = defineProps({
  event: Object,
  eventable: Object
});

const { t } = useI18n();

const headline = computed(() => {
  const actor = props.event.actor();
  return t(eventHeadline(props.event, true), { // useNesting
    author: actor.nameWithTitle(props.eventable.group()),
    username: actor.username,
    key: props.event.model().key,
    title: eventTitle(props.event),
    polltype: props.event.isPollEvent() ? t(eventPollType(props.event)).toLowerCase() : null
  });
});
</script>

<template lang="pug">
.strand-other-kind.text-body-2
  span.text-medium-emphasis(v-html='headline')
  mid-dot.text-medium-emphasis
  time-ago.text-medium-emphasis(:date='event.createdAt')
  //formatted-text.thread-item__body(:model="eventable" field="statement")
</template>