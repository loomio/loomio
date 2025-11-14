<script setup lang="js">
import { ref, computed, onMounted } from 'vue';
import Session from '@/shared/services/session';
import { pick, pickBy, assign } from 'lodash-es';
import CommentService from '@/shared/services/comment_service';
import EventService from '@/shared/services/event_service';

const props = defineProps({
  event: Object,
  eventable: Object,
  focused: Boolean,
  unread: Boolean
});

const confirmOpts = ref(null);
const commentActions = ref([]);
const eventActions = ref([]);

const rebuildActions = () => {
  commentActions.value = CommentService.actions(props.eventable, this, props.event);
  eventActions.value = EventService.actions(props.event, this);
};

const viewed = (seen) => {
  if (seen &&
      Session.isSignedIn() &&
      Session.user().autoTranslate &&
      commentActions.value['translate_comment'].canPerform()) {
    commentActions.value['translate_comment'].perform().then(() => { rebuildActions(); });
  }
};

const dockActions = computed(() => {
  return assign(
    pickBy(commentActions.value, v => v.dock)
  ,
    pick(eventActions.value, [])
  );
});

const menuActions = computed(() => {
  const actions = assign(
    pick(eventActions.value, ['pin_event', 'unpin_event', 'move_event', 'copy_url'])
  ,
    pickBy(commentActions.value, v => v.menu)
  );
  return pick(actions, ['pin_event', 'unpin_event', 'reply_to_comment',  'admin_edit_comment', 'copy_url', 'notification_history', 'move_event', 'discard_comment', 'undiscard_comment']);
});

onMounted(() => {
  rebuildActions();
});
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