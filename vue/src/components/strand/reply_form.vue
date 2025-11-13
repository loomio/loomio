<script setup lang="js">
import { ref, onMounted, onUnmounted } from 'vue';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import { startCase } from 'lodash-es';

const props = defineProps({
  eventId: Number
});

const show = ref(false);
const newComment = ref(null);

const handleToggleReply = (eventable, eventId) => {
  if (eventId === props.eventId) {
    if (show.value) {
      show.value = false;
    } else {
      let body = ""; 
      const op = eventable.author();
      if (op.id !== Session.user().id) {
        if (Session.defaultFormat() === 'html') {
          body = `<p><span class="mention" data-mention-id="${op.username}" label="${op.name}">@${op.nameOrUsername()}</span>&thinsp;</p>`;
        } else {
          body = `@${op.username} `;
        }
      }

      newComment.value = Records.comments.build({
        bodyFormat: Session.defaultFormat(),
        body,
        discussionId: eventable.discussion().id,
        authorId: Session.user().id,
        parentId: eventable.id,
        parentType: startCase(eventable.constructor.singular)
      });
      show.value = true;
    }
  }
};

onMounted(() => {
  EventBus.$on('toggle-reply', handleToggleReply);
});

onUnmounted(() => {
  EventBus.$off('toggle-reply', handleToggleReply);
});
</script>

<template lang="pug">
.reply-form(v-if="show")
  //- p reply formwrapper {{eventable.constructor.singular}}

  comment-form(
    :comment="newComment"
    avatar-size="32"
    @comment-submitted="show = false"
    @cancel-reply="show = false"
    autofocus)


</template>