<script setup lang="js">
import { computed, ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import { I18n } from '@/i18n';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { hardReload } from '@/shared/helpers/window';

const { topic } = defineProps({
  topic: { type: Object, required: true }
});

const router = useRouter();
const { t } = useI18n();
const destinationId = ref(null);
const availableGroups = computed(() => Session.user().groups());
const loading = ref(false);
const moveAccess = ref(null);
const accessLoading = ref(false);
const accessError = ref(false);
const accessRetry = ref(0);
const retainMembersAsGuests = ref(false);

const directAllowed = computed(() => topic.hasAnonymousPolls === false);
const isDirect = computed(() => destinationId.value === 'direct');
const destinationItems = computed(() => [{
  title: I18n.global.t('move_discussion_form.direct_thread'),
  value: 'direct',
  props: { disabled: !directAllowed.value || !topic.groupId }
}].concat(availableGroups.value.map(group => ({
  title: group.fullName,
  value: group.id
}))));

const targetGroup = () => Records.groups.find(destinationId.value);
const needsAccessPreview = computed(() => destinationId.value && (isDirect.value
  ? directAllowed.value && !!topic.groupId
  : destinationId.value !== topic.groupId));

watch([destinationId, accessRetry], async ([id], previous, onCleanup) => {
  let cancelled = false;
  onCleanup(() => { cancelled = true; });
  moveAccess.value = null;
  accessLoading.value = false;
  accessError.value = false;
  retainMembersAsGuests.value = false;
  if (!needsAccessPreview.value) { return; }

  accessLoading.value = true;
  try {
    const params = isDirect.value ? {make_direct: true} : {group_id: id};
    const result = await Records.topics.remote.getMember(topic.id, 'move_access', params);
    if (!cancelled) { moveAccess.value = result; }
  } catch (error) {
    if (!cancelled) { accessError.value = true; }
  } finally {
    if (!cancelled) { accessLoading.value = false; }
  }
});

const submit = () => {
  loading.value = true;
  const params = isDirect.value
    ? { group_id: null, make_direct: true, retain_members_as_guests: retainMembersAsGuests.value }
    : { group_id: destinationId.value, retain_members_as_guests: retainMembersAsGuests.value };

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
</script>

<template lang="pug">
v-card.move-topic-form(:title="$t('move_discussion_form.move_thread_title')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    v-select#group-dropdown.move-topic-form__group-dropdown(
      v-model="destinationId"
      :disabled="loading"
      :required="true"
      :items="destinationItems"
      :label="$t('move_discussion_form.destination')")
    v-progress-linear(v-if="accessLoading" indeterminate)
    v-alert.move-topic-form__access-error(v-if="accessError" type="error" variant="tonal")
      | {{ t('move_discussion_form.access_preview_error') }}
      v-btn.move-topic-form__retry(@click="accessRetry++") {{ t('common.action.retry') }}
    v-alert.move-topic-form__access-warning(
      v-if="moveAccess && moveAccess.members_losing_access_count > 0"
      type="warning"
      variant="tonal")
      p {{ t('move_discussion_form.members_losing_access', {count: moveAccess.members_losing_access_count}) }}
      v-checkbox.move-topic-form__retain-members(
        v-if="moveAccess.can_retain_members_as_guests"
        v-model="retainMembersAsGuests"
        :disabled="loading"
        :label="t('move_discussion_form.keep_members_as_guests')"
        hide-details)
      p(v-else) {{ t('move_discussion_form.guest_access_unavailable') }}
    v-alert.move-topic-form__direct-hint(
      v-if="isDirect"
      type="info"
      variant="tonal"
      density="compact")
      span {{ t('move_discussion_form.direct_thread_hint') }}
    v-alert.move-topic-form__direct-anonymous-warning(
      v-if="!directAllowed"
      type="warning"
      variant="tonal"
      density="compact")
      span {{ t('move_discussion_form.direct_thread_anonymous_poll') }}
  v-card-actions
    v-spacer
    v-btn.move-topic-form__submit(
      :disabled="loading || !destinationId || (isDirect && (!directAllowed || !topic.groupId)) || (!isDirect && topic.groupId == destinationId) || (needsAccessPreview && !moveAccess)"
      :loading="loading"
      color="primary"
      variant="tonal"
      @click="moveThread")
      span {{ t('move_discussion_form.confirm') }}
</template>
