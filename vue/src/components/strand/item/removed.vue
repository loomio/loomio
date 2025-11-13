<script setup lang="js">
import { computed } from 'vue';
import CommentService from '@/shared/services/comment_service';
import { pick } from 'lodash-es';

const props = defineProps({
  event: Object,
  eventable: Object
});

const menuActions = computed(() => {
  if (props.event.kind === 'new_comment') {
    return pick(CommentService.actions(props.eventable, this), 'undiscard_comment', 'delete_comment');
  } else {
    return {};
  }
});
</script>

<template lang="pug">
section.strand-item__removed
  h3.strand-item__headline.text-body-2.pb-1.d-flex.align-center.text-medium-emphasis
    span(v-t="'thread_item.removed'")
    mid-dot
    time-ago(:date='eventable.discardedAt')
  action-dock(:model='eventable' :menu-actions='menuActions' size="small")
</template>