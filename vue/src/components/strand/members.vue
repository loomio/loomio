<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import {map} from 'lodash-es';

export default {
  props: {
    discussion: Object
  },

  data() {
    return {readers: []};
  },

  mounted() {
    Records.discussionReaders.fetch({
      path: '',
      params: {
        discussion_id: this.discussion.id
      }
    });

    this.watchRecords({
      collections: ['discussionReaders'],
      query: records => {
        this.readers = Records.discussionReaders.collection.chain().
          find({discussionId: this.discussion.id}).simplesort('lastReadAt', true).limit(20).data();
      }
    });
  },

  methods: {
    openInviteModal() {
      EventBus.$emit('openModal', {
        component: 'StrandMembersList',
        props: { discussion: this.discussion }
      });
    }
  }
};

</script>

<template lang="pug">
.strand-members.d-flex
  //- mid-dot
  //- span(v-show='discussion.seenByCount > 0')
  //-   a.context-panel__seen_by_count(v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }"  @click="openSeenByModal()")

  user-avatar(v-for="reader in readers" :user="reader.user()" :size="28" :key="reader.id")
  v-btn(small icon @click="openInviteModal" :title="$t('invitation_form.invite_people')")
    common-icon(name="mdi-plus")
</template>

<style lang="sass">
</style>
