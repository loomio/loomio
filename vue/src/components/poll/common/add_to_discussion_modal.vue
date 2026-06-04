<script setup lang="js">
import { ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import { sortBy, debounce } from 'lodash-es';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { useCurrentUserGroups } from '@/composables/useCurrentUserGroups';

const props = defineProps({
  poll: Object
});

const router = useRouter();
const urlFor = (model, action, params) => LmoUrlService.route({model, action, params});

const selectedTopic = ref(null);
const searchFragment = ref('');
const searchResults = ref([]);
const groupId = ref(props.poll.topic().groupId);
const groups = ref([]);
const loading = ref(false);

const { loadGroups } = useCurrentUserGroups();
loadGroups().then(() => {
  groups.value = sortBy(Session.user().groups(), 'fullName');
});

const canMoveTo = (topic) => {
  return topic.id !== props.poll.topicId &&
         topic.topicableType === 'Discussion' &&
         topic.adminsInclude(Session.user());
};

const updateResults = () => {
  const frag = searchFragment.value.toLowerCase();
  searchResults.value = Records.topics.collection.chain()
    .find({groupId: groupId.value, topicableType: 'Discussion'})
    .where(t => {
      if (!canMoveTo(t)) { return false; }
      if (!frag) { return true; }
      const discussion = t.discussion();
      return discussion && discussion.title.toLowerCase().includes(frag);
    })
    .simplesort('lastActivityAt', true)
    .data();
};

const fetchTopics = debounce(() => {
  loading.value = true;
  const params = {
    group_id: groupId.value,
    topicable_type: 'Discussion',
    exclude_types: 'reaction group',
    per: 50
  };
  if (searchFragment.value) {
    params.q = searchFragment.value;
  }
  Records.topics.fetch({params}).finally(() => {
    loading.value = false;
    updateResults();
  });
}, 500);

const submit = () => {
  const event = props.poll.createdEvent();
  if (!event) { return; }

  loading.value = true;
  selectedTopic.value.moveComments([event.id]).then(() => {
    loading.value = false;
    Flash.success("add_poll_to_discussion_modal.success", {pollType: props.poll.translatedPollType()});
    router.push(urlFor(selectedTopic.value)).then(() => {
      EventBus.$emit('closeModal');
    });
  });
};

const newQuery = (q) => {
  searchFragment.value = q || '';
  fetchTopics();
};

watch(groupId, fetchTopics);

// init
fetchTopics();

const { watchRecords } = useWatchRecords();
watchRecords({
  collections: ['topics'],
  query: () => updateResults()
});
</script>

<template lang="pug">
v-card(:title="$t('add_poll_to_discussion_modal.title')")
  template(v-slot:append)
    dismiss-modal-button(aria-hidden='true')
  v-card-text
    v-alert(type="info" variant="tonal" class="mb-4")
      | {{ $t('add_poll_to_discussion_modal.explanation', {pollType: poll.translatedPollType()}) }}
    v-select(v-model="groupId" :items="groups" item-title="fullName" item-value="id")
    v-autocomplete(hide-no-data return-object v-model="selectedTopic" @update:search="newQuery" :items="searchResults" item-title="title" :placeholder="$t('discussion_fork_actions.search_placeholder')" :label="$t('common.discussion')" :loading="loading")
  v-card-actions
    v-spacer
    v-btn(color="primary" @click="submit()" :disabled="!selectedTopic" :loading="loading")
      span(v-t="'common.action.add'")
</template>
