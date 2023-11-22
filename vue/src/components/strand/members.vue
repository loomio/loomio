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

<template>

<div class="strand-members d-flex">
  <user-avatar v-for="reader in readers" :user="reader.user()" :size="28" :key="reader.id"></user-avatar>
  <v-btn small="small" icon="icon" @click="openInviteModal" :title="$t('invitation_form.invite_people')">
    <common-icon name="mdi-plus"></common-icon>
  </v-btn>
</div>
</template>

<style lang="sass">
</style>
