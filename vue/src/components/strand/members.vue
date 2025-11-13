<script setup lang="js">
import { ref, onMounted } from 'vue';
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import { useWatchRecords } from '@/shared/composables/use_watch_records';

const props = defineProps({
  discussion: Object
});

const readers = ref([]);
const { watchRecords } = useWatchRecords();

const openInviteModal = () => {
  EventBus.$emit('openModal', {
    component: 'StrandMembersList',
    props: { discussion: props.discussion }
  });
};

onMounted(() => {
  Records.discussionReaders.fetch({
    path: '',
    params: {
      discussion_id: props.discussion.id
    }
  });

  watchRecords({
    collections: ['discussionReaders'],
    query: records => {
      readers.value = Records.discussionReaders.collection.chain().
        find({discussionId: props.discussion.id}).simplesort('lastReadAt', true).limit(20).data();
    }
  });
});
</script>

<template lang="pug">
.strand-members.d-flex
  //- mid-dot
  //- span(v-show='discussion.seenByCount > 0')
  //-   a.context-panel__seen_by_count(v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }"  @click="openSeenByModal()")

  user-avatar(v-for="reader in readers" :user="reader.user()" :size="28" :key="reader.id")
  v-btn(size="small" icon @click="openInviteModal" :title="$t('invitation_form.invite_people')")
    common-icon(name="mdi-plus")
</template>

<style lang="sass">
</style>