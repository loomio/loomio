<script setup lang="js">
import { computed, ref } from 'vue';
import { useRouter } from 'vue-router';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import { I18n } from '@/i18n';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { hardReload } from '@/shared/helpers/window';

const { topic } = defineProps({
  topic: { type: Object, required: true }
});

const router = useRouter();
const { watchRecords } = useWatchRecords();
const destinationId = ref(null);
const availableGroups = ref([]);
const loading = ref(false);

const directAllowed = computed(() => topic.anonymousPollsCount === 0);
const isDirect = computed(() => destinationId.value === 'direct');
const destinationItems = computed(() => [{
  title: I18n.global.t('move_discussion_form.direct_thread'),
  value: 'direct',
  props: { disabled: !directAllowed.value }
}].concat(availableGroups.value.map(group => ({
  title: group.fullName,
  value: group.id
}))));

const targetGroup = () => Records.groups.find(destinationId.value);

const submit = () => {
  loading.value = true;
  const params = isDirect.value
    ? { group_id: null, make_direct: true }
    : { group_id: destinationId.value };

  Records.topics.remote.patchMember(topic.id, 'move', params).then(() => {
    const groupId = isDirect.value ? null : destinationId.value;
    const storedTopic = Records.topics.find(topic.id);
    [topic, storedTopic].forEach(record => {
      record.update({groupId});
      record.topicable().update({groupId});
    });

    if (!isDirect.value) {
      Flash.success('move_discussion_form.messages.success', { name: targetGroup().name });
    }
    EventBus.$emit('closeModal');
    const route = LmoUrlService.route({model: storedTopic.topicable()});
    if (isDirect.value) {
      hardReload(route);
    } else {
      router.push(route);
    }
  }).catch(error => {
    Flash.serverError(error);
  }).finally(() => {
    loading.value = false;
  });
};

const moveThread = () => {
  if (!isDirect.value && topic.private && targetGroup().privacyIsOpen()) {
    if (confirm(I18n.global.t('move_discussion_form.confirm_change_to_private', {groupName: targetGroup().name}))) {
      submit();
    }
  } else {
    submit();
  }
};

watchRecords({
  collections: ['groups', 'memberships'],
  query: () => {
    availableGroups.value = Session.user().groups();
  }
});
</script>

<template lang="pug">
v-card.move-thread-form(:title="$t('move_discussion_form.move_thread_title')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    v-select#group-dropdown.move-thread-form__group-dropdown(
      v-model="destinationId"
      :required="true"
      :items="destinationItems"
      :label="$t('move_discussion_form.destination')")
    v-alert.move-thread-form__direct-hint(
      v-if="isDirect"
      type="info"
      variant="tonal"
      density="compact")
      span(v-t="'move_discussion_form.direct_thread_hint'")
    v-alert.move-thread-form__direct-anonymous-warning(
      v-if="!directAllowed"
      type="warning"
      variant="tonal"
      density="compact")
      span(v-t="'move_discussion_form.direct_thread_anonymous_poll'")
  v-card-actions
    v-spacer
    v-btn.move-thread-form__submit(
      :disabled="!destinationId || (!isDirect && topic.groupId == destinationId)"
      :loading="loading"
      color="primary"
      variant="tonal"
      @click="moveThread")
      span(v-t="'move_discussion_form.confirm'")
</template>
