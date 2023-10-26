<script lang="js">
import AbilityService from '@/shared/services/ability_service';

import { pick, pickBy, assign, compact } from 'lodash';
import CommentService from '@/shared/services/comment_service';
import EventService from '@/shared/services/event_service';
import Session from '@/shared/services/session';

export default {
  props: {
    event: Object,
    eventable: Object
  },

  data() {
    return {
      confirmOpts: null,
      commentActions: CommentService.actions(this.eventable, this, this.event),
      eventActions: EventService.actions(this.event, this)
    };
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
section.strand-item__new-comment.new-comment(:id="'comment-'+ eventable.id")
  strand-item-headline(:event="event" :eventable="eventable")
  formatted-text.thread-item__body.new-comment__body(:model="eventable" column="body")
  link-previews(:model="eventable")
  document-list(:model='eventable')
  attachment-list(:attachments="eventable.attachments")
  action-dock(:model='eventable' :actions='dockActions' :menu-actions='menuActions' small left)
</template>
