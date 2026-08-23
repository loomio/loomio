<script lang="js">
import CommentService from '@/shared/services/comment_service';
import { pick } from 'lodash-es';
export default {
  props: {
    topic_item: Object,
    itemable: Object
  },

  computed: {
    menuActions() {
      if (this.topic_item.kind === 'new_comment') {
        return pick(CommentService.actions(this.itemable, this), 'undiscard_comment', 'delete_comment');
      } else {
        return {};
      }
    }
  }
};
</script>

<template lang="pug">
section.strand-item__removed
  h3.strand-item__headline.text-body-medium.pb-1.d-flex.align-center.text-medium-emphasis
    span(v-t="'thread_item.removed'")
    mid-dot
    time-ago(:date='itemable.discardedAt')
  action-dock(:model='itemable' :menu-actions='menuActions' size="small")
</template>
