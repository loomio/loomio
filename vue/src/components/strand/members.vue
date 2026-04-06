<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';

export default {
  props: {
    discussion: Object
  },

  data() {
    return {readers: []};
  },

  mounted() {
    Records.topicReaders.fetch({
      params: {
        discussion_id: this.discussion.id
      }
    });

    this.watchRecords({
      collections: ['topicReaders'],
      query: records => {
        this.readers = Records.topicReaders.collection.chain().
          find({topicId: this.discussion.topicId}).simplesort('lastReadAt', true).limit(20).data();
      }
    });
  },

  methods: {
    openInviteModal() {
      EventBus.$emit('openModal', {
        component: 'StrandMembersList',
        props: { topic: this.discussion.topic() }
      });
    }
  }
};

</script>

<template lang="pug">
.strand-members.d-flex
  //- mid-dot
  //- span(v-show='discussion.seenByCount > 0')
  //-   a.context-panel__seen_by_count(v-t="{ path: 'discussion_context.seen_by_count', args: { count: discussion.seenByCount } }"  @click="openSeenByModal()")

  user-avatar(v-for="reader in readers" :user="reader.user()" :size="28" :key="reader.id")
  v-btn(size="small" icon @click="openInviteModal" :title="$t('invitation_form.invite_people')")
    common-icon(name="mdi-plus")
</template>

<style lang="sass">
</style>
