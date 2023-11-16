<script lang="js">
import CommentService from '@/shared/services/comment_service';
import { pick } from 'lodash-es';
export default {
  props: {
    event: Object,
    eventable: Object
  },

  computed: {
    menuActions() {
      if (this.event.kind === 'new_comment') {
        return pick(CommentService.actions(this.eventable, this), 'undiscard_comment', 'delete_comment');
      } else {
        return {};
      }
    }
  }
};
</script>

<template lang="pug">
section.strand-item__removed
  h3.strand-item__headline.text-body-2.pb-1.d-flex.align-center.text--secondary
    span(v-t="'thread_item.removed'")
    mid-dot
    time-ago(:date='eventable.discardedAt')
  action-dock(:model='eventable' :menu-actions='menuActions' small)
</template>
