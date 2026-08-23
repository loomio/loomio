<script lang="js">
import Session from '@/shared/services/session';
import { pick, pickBy, assign } from 'lodash-es';
import CommentService from '@/shared/services/comment_service';
import TopicItemService from '@/shared/services/topic_item_service';

export default {
  props: {
    topic_item: Object,
    itemable: Object,
    focused: Boolean,
    unread: Boolean
  },

  data() {
    return {
      confirmOpts: null,
      commentActions: [],
      eventActions: []
    };
  },

  mounted() {
    this.rebuildActions();
  },

  methods: {
    rebuildActions() {
      this.commentActions = CommentService.actions(this.itemable, this, this.topic_item);
      this.eventActions = TopicItemService.actions(this.topic_item, this);
    },

    viewed(seen) {
      if (seen &&
          Session.isSignedIn() &&
          Session.user().autoTranslate &&
          this.commentActions['translate_comment'].canPerform()) {
        this.commentActions['translate_comment'].perform().then(() => { this.rebuildActions() });
      }
    },
  },

  computed: {
    dockActions() {
      return assign(
        pickBy(this.commentActions, v => v.dock)
      ,
        pick(this.eventActions, [])
      );
    },

    menuActions() {
      const actions = assign(
        pick(this.eventActions, ['pin_event', 'unpin_event', 'move_event', 'copy_url'])
      ,
        pickBy(this.commentActions, v => v.menu)
      );
      return pick(actions, ['save_bookmark', 'remove_bookmark', 'pin_event', 'unpin_event', 'reply_to_comment',  'admin_edit_comment', 'copy_url', 'notification_history', 'move_event', 'discard_comment', 'undiscard_comment']);
    }
  }
};

</script>

<template lang="pug">
section.topic-item__new-comment.new-comment(:id="'comment-'+ itemable.id" v-intersect.once="{handler: viewed}")
  topic-item-headline(:topic_item="topic_item" :itemable="itemable" :focused="focused" :unread="unread")
  formatted-text.thread-item__body.new-comment__body(:model="itemable" field="body")
  //link-previews(:model="itemable")
  attachment-list(:attachments="itemable.attachments")
  action-dock(:model='itemable' :actions='dockActions' :menu-actions='menuActions' size="small" left)
</template>
