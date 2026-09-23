<script lang="js">
import NewComment from '@/components/topic_items/new_comment.vue';
import NewDiscussion from '@/components/topic_items/new_discussion.vue';
import DiscussionEdited from '@/components/topic_items/discussion_edited.vue';
import PollEdited from '@/components/topic_items/poll_edited.vue';
import PollCreated from '@/components/topic_items/poll_created.vue';
import StanceCreated from '@/components/topic_items/stance_created.vue';
import StanceUpdated from '@/components/topic_items/stance_updated.vue';
import OutcomeCreated from '@/components/topic_items/outcome_created.vue';
import TopicItemRemoved from '@/components/topic_items/removed.vue';
import OtherKind from '@/components/topic_items/other_kind.vue';

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
    TopicItemRemoved,
  },

  methods: {
    componentForKind(kind) {
      return camelCase(['stance_created', 'stance_updated', 'discussion_edited', 'new_comment', 'outcome_created', 'poll_created', 'poll_edited', 'new_discussion'].includes(kind) ?
        kind
        :
        'other_kind'
      );

    },
    classes(topic_item) {
      if (!topic_item) { return []; }
      return [
        "lmo-action-dock-wrapper",
        `positionKey-${topic_item.positionKey}`,
        `sequenceId-${topic_item.sequenceId}`
      ];
    }
  }
};

</script>

<template lang="pug">
div.topic-item__intersection-container(:class="classes(obj.topic_item)" v-intersect="{handler: (isVisible) => loader.setVisible(isVisible, obj.topic_item)}")
  //p eventid{{obj.topic_item.id}} t{{obj.topic_item.topicId}} s{{obj.topic_item.sequenceId}} p{{obj.topic_item.positionKey}} d{{obj.topic_item.depth}} p{{obj.topic_item.parentId}}
  topic-item-removed(v-if="obj.itemable && obj.itemable.discardedAt" :topic_item="obj.topic_item" :itemable="obj.itemable")
  component(v-else :is="componentForKind(obj.topic_item.kind)" :topic_item='obj.topic_item' :itemable="obj.itemable" :focused="focused" :unread="obj.isUnread")


</template>
