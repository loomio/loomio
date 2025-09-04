<script lang="js">
import NewComment from '@/components/strand/item/new_comment.vue';
import NewDiscussion from '@/components/strand/item/new_discussion.vue';
import DiscussionEdited from '@/components/strand/item/discussion_edited.vue';
import PollEdited from '@/components/strand/item/poll_edited.vue';
import PollCreated from '@/components/strand/item/poll_created.vue';
import StanceCreated from '@/components/strand/item/stance_created.vue';
import StanceUpdated from '@/components/strand/item/stance_updated.vue';
import OutcomeCreated from '@/components/strand/item/outcome_created.vue';
import StrandItemRemoved from '@/components/strand/item/removed.vue';
import OtherKind from '@/components/strand/item/other_kind.vue';

import { camelCase } from 'lodash-es';

export default {
  props: {
    loader: Object,
    obj: Object,
    focused: Boolean
  },

  components: {
    NewDiscussion,
    NewComment,
    PollCreated,
    StanceCreated,
    StanceUpdated,
    OutcomeCreated,
    OtherKind,
    DiscussionEdited,
    PollEdited,
    StrandItemRemoved,
  },

  methods: {
    componentForKind(kind) {
      return camelCase(['stance_created', 'stance_updated', 'discussion_edited', 'new_comment', 'outcome_created', 'poll_created', 'poll_edited', 'new_discussion'].includes(kind) ?
        kind
        :
        'other_kind'
      );

    },
    classes(event) {
      if (!event) { return []; }
      return [
        "lmo-action-dock-wrapper",
        `positionKey-${event.positionKey}`,
        `sequenceId-${event.sequenceId || 0}`
      ];
    }
  }
};

</script>

<template lang="pug">
div.strand-item__intersection-container(:class="classes(obj.event)" v-intersect="{handler: (isVisible) => loader.setVisible(isVisible, obj.event)}")
  //p {{obj.event.sequenceId}} {{obj.event.positionKey}}
  strand-item-removed(v-if="obj.eventable && obj.eventable.discardedAt" :event="obj.event" :eventable="obj.eventable")
  component(v-else :is="componentForKind(obj.event.kind)" :event='obj.event' :eventable="obj.eventable" :focused="focused" :unread="obj.isUnread")


</template>
