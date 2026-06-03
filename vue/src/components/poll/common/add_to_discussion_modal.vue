<script setup lang="js">
import { ref, watch, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import { sortBy, debounce } from 'lodash-es';
import LmoUrlService from '@/shared/services/lmo_url_service';

const props = defineProps({
  poll: Object
});

const router = useRouter();
const urlFor = (model, action, params) => LmoUrlService.route({model, action, params});

const selectedTopic = ref(null);
const searchFragment = ref('');
const searchResults = ref([]);
const groupId = ref(props.poll.topic().groupId);
const groups = sortBy(Session.user().groups(), 'fullName');
const loading = ref(false);

const canMoveTo = (topic) => {
  return topic.id !== props.poll.topicId &&
         topic.topicableType === 'Discussion' &&
         topic.adminsInclude(Session.user());
};

const getSuggestions = () => {
  loading.value = true;
  Records.topics.fetch({
    params: {
      group_id: groupId.value,
      topicable_type: 'Discussion',
      exclude_types: 'reaction',
      per: 50
    }
  }).then(() => {
    loading.value = false;
    searchResults.value = Records.topics.collection.chain()
      .find({groupId: groupId.value, topicableType: 'Discussion'})
      .where(t => canMoveTo(t))
      .simplesort('lastActivityAt', true)
      .data();
  });
};

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

const fetch = debounce(() => {
  if (!searchFragment.value) {
    getSuggestions();
    return;
  }

  loading.value = true;
  Records.topics.fetch({
    params: {
      group_id: groupId.value,
      topicable_type: 'Discussion',
      q: searchFragment.value,
      per: 20
    }
  }).then(() => {
    loading.value = false;
    const frag = searchFragment.value.toLowerCase();
    searchResults.value = Records.topics.collection.chain()
      .find({groupId: groupId.value, topicableType: 'Discussion'})
      .where(t => {
        const discussion = t.discussion();
        return discussion &&
               canMoveTo(t) &&
               discussion.title.toLowerCase().includes(frag);
      })
      .simplesort('lastActivityAt', true)
      .data();
  });
}, 500);

watch(searchFragment, fetch);
watch(groupId, getSuggestions);
onMounted(getSuggestions);
</script>

<template lang="pug">
v-card(:title="$t('add_poll_to_discussion_modal.title')")
  template(v-slot:append)
    dismiss-modal-button(aria-hidden='true')
  v-card-text
    v-select(v-model="groupId" :items="groups" item-title="fullName" item-value="id")
    v-autocomplete(hide-no-data return-object v-model="selectedTopic" :search-input.sync="searchFragment" :items="searchResults" item-title="title" :placeholder="$t('discussion_fork_actions.search_placeholder')" :label="$t('add_poll_to_discussion_modal.discussion')" :loading="loading")
  v-card-actions
    v-spacer
    v-btn(color="primary" @click="submit()" :disabled="!selectedTopic" :loading="loading")
      span(v-t="'common.action.save'")
</template>
