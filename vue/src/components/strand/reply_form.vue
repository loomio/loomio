<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import { startCase } from 'lodash-es';

export default {
  props: {
    eventId: Number
  },

  data() {
    return {
      show: false,
      newComment: null
    };
  },

  created() {
    EventBus.$on('toggle-reply', (eventable, eventId) => {
      if (eventId === this.eventId) {
        if (this.show) {
          this.show = false;
        } else {
          let body = ""; 
          const op = eventable.author();
          if (op.id !== Session.user().id) {
            if (Session.defaultFormat() === 'html') {
              body = `<p><span class=\"mention\" data-mention-id=\"${op.username}\" label=\"${op.name}\">@${op.nameOrUsername()}</span>&thinsp;</p>`;
            } else {
              body = `@${op.username} `;
            }
          }

          const discussion = eventable.discussion ? eventable.discussion() : null;
          this.newComment = Records.comments.build({
            bodyFormat: Session.defaultFormat(),
            body,
            discussionId: discussion ? discussion.id : null,
            authorId: Session.user().id,
            parentId: eventable.id,
            parentType: startCase(eventable.constructor.singular)
          });
          this.show = true;
        }
      }
    });
  },

  destroyed() {}
};
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
