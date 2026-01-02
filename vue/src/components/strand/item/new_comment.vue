<script lang="js">
import Session from '@/shared/services/session';
import { pick, pickBy, assign } from 'lodash-es';
import CommentService from '@/shared/services/comment_service';
import EventService from '@/shared/services/event_service';

export default {
  props: {
    event: Object,
    eventable: Object,
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
      this.commentActions = CommentService.actions(this.eventable, this, this.event);
      this.eventActions = EventService.actions(this.event, this);
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
      return pick(actions, ['pin_event', 'unpin_event', 'reply_to_comment',  'admin_edit_comment', 'copy_url', 'notification_history', 'move_event', 'discard_comment', 'undiscard_comment']);
    }
  }
};

</script>

<template lang="pug">
section.strand-item__new-comment.new-comment(:id="'comment-'+ eventable.id" v-intersect.once="{handler: viewed}")
  strand-item-headline(:event="event" :eventable="eventable" :focused="focused" :unread="unread")
  formatted-text.thread-item__body.new-comment__body(:model="eventable" field="body")
  link-previews(:model="eventable")
  document-list(:model='eventable')
  attachment-list(:attachments="eventable.attachments")
  action-dock(:model='eventable' :actions='dockActions' :menu-actions='menuActions' size="small" left)
</template>
