<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import TopicAbility from '@/shared/abilities/topic_ability';

export default {
  props: {
    discussion: Object
  },

  mounted() {
    Records.topicReaders.fetch({
      params: {
        discussion_id: this.discussion.id
      }
    });
  },

  methods: {
    openInviteModal() {
      EventBus.$emit('openModal', {
        component: 'TopicMembersList',
        props: { topic: this.discussion.topic() }
      });
    }
  },

  computed: {
    readers() {
      return Records.topicReaders.collection.chain().
        find({topicId: this.discussion.topicId}).simplesort('lastReadAt', true).limit(20).data();
    },
    canInvitePeople() {
      const topic = this.discussion.topic();
      return (!topic.lockedAt && TopicAbility.announce(topic)) || TopicAbility.addGuests(topic);
    }
  }
};

</script>

<template lang="pug">
.topic-members.d-flex
  //- mid-dot
  //- span(v-show='discussion.seenByCount > 0')
  //-   a.context-panel__seen_by_count(v-t="{ path: 'discussion_context.seen_by_count', args: { count: discussion.seenByCount } }"  @click="openSeenByModal()")

  user-avatar(v-for="reader in readers" :user="reader.user()" :size="28" :key="reader.id")
  v-btn(v-if="canInvitePeople" size="small" icon @click="openInviteModal" :title="$t('invitation_form.invite_people')")
    common-icon(name="mdi-plus")
</template>
