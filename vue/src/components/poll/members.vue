<script setup lang="js">
import { computed, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { map, debounce } from 'lodash-es';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import StanceService from '@/shared/services/stance_service';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { voteWeightValid } from '@/shared/helpers/vote_weight';

const { poll } = defineProps({ poll: Object });
const { t } = useI18n();
const { watchRecords } = useWatchRecords();

const limit = 50;
const initialRecipients = [];
const users = ref([]);
const userIds = ref([]);
const isGuest = ref({});
const isGroupAdmin = ref({});
const isTopicAdmin = ref({});
const reset = ref(false);
const saving = ref(false);
const loading = ref(false);
const query = ref('');
const message = ref('');
const stanceIdsByUserId = ref({});
const weightsByUserId = ref({});
const weightsSaving = ref(false);
const weightUser = ref(null);
const weightValue = ref('');
const weightDialog = ref(false);
const removeUser = ref(null);
const removeDialog = ref(false);
const removing = ref(false);
const resetWeight = ref('1');
const weightMode = ref('membership');
const setAllDialog = ref(false);
const voterTotal = ref(0);
const page = ref(1);
let fetchSequence = 0;

const isScheduled = computed(() => poll.openingAt && !poll.openedAt);
const someRecipients = computed(() => poll.recipientAudience ||
  poll.recipientUserIds.length ||
  poll.recipientEmails.length ||
  poll.recipientChatbotIds.length);
const canManageWeights = computed(() => poll.weightedVoting && !poll.closedAt && poll.adminsInclude(Session.user()));
const canRemoveVoters = computed(() => !poll.detachedAnonymousVoting() && poll.adminsInclude(Session.user()));
const canUseMemberWeights = computed(() => Boolean(poll.groupId));
const totalPages = computed(() => Math.max(1, Math.ceil(voterTotal.value / limit)));
const pageFirst = computed(() => voterTotal.value ? (page.value - 1) * limit + 1 : 0);
const pageLast = computed(() => Math.min(page.value * limit, voterTotal.value));

function isDelegate(user) {
  const group = poll.group();
  return Boolean(group && user.delegates && user.delegates[group.id]);
}

function toHash(ids) {
  return Object.fromEntries(ids.map(id => [id, true]));
}

function updateStances() {
  users.value = userIds.value.map(id => Records.users.findById(id));
}

// Keep the server's page, total, and voter metadata together; ignore responses
// from an older search or page.
const fetchStances = debounce(() => {
  loading.value = true;
  const currentQuery = query.value;
  const currentPage = page.value;
  const sequence = ++fetchSequence;
  Records.fetch({
    path: 'stances/users',
    params: {
      exclude_types: 'poll group',
      poll_id: poll.id,
      query: currentQuery,
      offset: (currentPage - 1) * limit,
      limit
    }
  }).then(data => {
    if (sequence !== fetchSequence || currentQuery !== query.value || currentPage !== page.value) return;
    voterTotal.value = data.meta.total;
    if (page.value > totalPages.value) {
      changePage(totalPages.value);
      return;
    }
    isGuest.value = toHash(data.meta.guest_ids);
    isGroupAdmin.value = toHash(data.meta.group_admin_ids);
    isTopicAdmin.value = toHash(data.meta.topic_admin_ids);
    if (canManageWeights.value) {
      Object.assign(stanceIdsByUserId.value, data.meta.stance_ids_by_user_id);
      Object.assign(weightsByUserId.value, data.meta.weights_by_user_id);
    }
    userIds.value = map(data.users, 'id');
    updateStances();
  }).catch(error => {
    Flash.fromServer(error);
  }).finally(() => {
    if (sequence === fetchSequence && currentQuery === query.value && currentPage === page.value) loading.value = false;
  });
}, 300);

function newQuery(value) {
  if (query.value === value) return;
  query.value = value;
  page.value = 1;
  userIds.value = [];
  users.value = [];
  voterTotal.value = 0;
  loading.value = true;
  fetchStances();
}

function changePage(value) {
  page.value = value;
  userIds.value = [];
  users.value = [];
  loading.value = true;
  fetchStances();
}

function openWeightDialog(user) {
  weightUser.value = user;
  weightValue.value = weightsByUserId.value[user.id];
  weightDialog.value = true;
}

function saveWeight() {
  if (weightsSaving.value || !voteWeightValid(weightValue.value)) return;
  const user = weightUser.value;
  weightsSaving.value = true;
  Records.remote.patch(`stances/${stanceIdsByUserId.value[user.id]}/set_weight`, {weight: weightValue.value}).then(data => {
    weightsByUserId.value[user.id] = data.stances[0].weight;
    return Records.polls.remote.fetchById(poll.id);
  }).then(() => {
    weightDialog.value = false;
    Flash.success('poll_common_form.vote_weights_updated');
  }).catch(error => {
    Flash.fromServer(error);
  }).finally(() => {
    weightsSaving.value = false;
  });
}

function openSetAllDialog() {
  weightMode.value = canUseMemberWeights.value ? 'membership' : 'value';
  setAllDialog.value = true;
}

function resetWeights() {
  weightsSaving.value = true;
  const params = {poll_id: poll.id, mode: weightMode.value};
  if (weightMode.value === 'value') params.weight = resetWeight.value;
  Records.remote.patch('stances/reset_weights', params).then(() => Records.polls.remote.fetchById(poll.id)).then(() => {
    weightsByUserId.value = {};
    fetchStances();
    setAllDialog.value = false;
    Flash.success('poll_common_form.vote_weights_updated');
  }).catch(error => Flash.fromServer(error)).finally(() => { weightsSaving.value = false; });
}

function openRemoveDialog(user) {
  removeUser.value = user;
  removeDialog.value = true;
}

function removeVoter() {
  const user = removeUser.value;
  removing.value = true;
  StanceService.revoke.perform(poll, user).then(() => {
    delete stanceIdsByUserId.value[user.id];
    delete weightsByUserId.value[user.id];
    fetchStances();
    removeDialog.value = false;
  }).catch(error => {
    Flash.fromServer(error);
  }).finally(() => {
    removing.value = false;
  });
}

function inviteRecipients() {
  saving.value = true;
  Records.remote.post('announcements', {
    poll_id: poll.id,
    recipient_audience: poll.recipientAudience,
    recipient_user_ids: poll.recipientUserIds,
    recipient_chatbot_ids: poll.recipientChatbotIds,
    recipient_emails: poll.recipientEmails,
    include_actor: true,
    recipient_message: message.value,
    exclude_members: true,
    notify_recipients: poll.notifyRecipients
  }).then(data => {
    const count = (data.stances || data.users).length;
    if (poll.notifyRecipients) {
      Flash.success('announcement.flash.success', { count });
    } else {
      Flash.success('poll_common_form.count_voters_added', { count });
    }
    fetchStances();
    reset.value = !reset.value;
  }).catch(error => {
    Flash.fromServer(error.flash || error);
  }).finally(() => {
    saving.value = false;
  });
}

onMounted(() => {
  poll.notifyRecipients = !(poll.openingAt && !poll.openedAt);
  fetchStances();
  updateStances();
  watchRecords({
    collections: ['stances', 'memberships', 'users'],
    query: () => updateStances()
  });
});
</script>

<template lang="pug">
v-card.poll-members-form(:title="t('poll_common_form.manage_voters')" style="height: 760px; max-height: 90vh; flex: none; display: flex; flex-direction: column; overflow-y: auto")
  template(v-slot:append)
    help-btn.text-medium-emphasis.mr-2(path="en/user_manual/polls/inviting_people#add-voters-to-the-poll" label="common.user_manual" variant="text")
    dismiss-modal-button
  .px-4.pt-4
    recipients-autocomplete(
      v-if="!poll.closedAt"
      :label="t('poll_common_form.find_or_invite_voters')"
      :placeholder="t('announcement.form.placeholder')"
      :model="poll"
      :reset="reset"
      :excludedAudiences="['voters', 'undecided_voters', 'non_voters', 'decided_voters']"
      :excludedUserIds="userIds"
      :initialRecipients="initialRecipients"
      hideEmptyMenu
      preserveSearchOnBlur
      @update:search="newQuery"
      includeActor
      :excludeMembers="true")
    v-alert(density="compact" type="info" text v-if="!poll.closedAt && isScheduled && someRecipients")
      span {{ t('poll_common_form.voters_notified_when_opens') }}
    .mt-3(v-if="!poll.closedAt && !isScheduled && someRecipients")
      v-textarea(v-if="poll.notifyRecipients" filled rows="3" hide-details v-model="message" :label="t('announcement.form.invitation_message_label')" :placeholder="t('announcement.form.invitation_message_placeholder')")
      v-alert(v-else density="compact" type="info" variant="outlined" color="grey" text)
        span {{ t('poll_common_form.voters_will_not_be_notified') }}
    .d-flex.align-center.mt-4(v-if="!poll.closedAt && someRecipients")
      v-checkbox(v-if="!isScheduled" :label="t('poll_common_form.notify_invitees')" v-model="poll.notifyRecipients" hide-details)
      v-spacer
      v-btn.poll-members-form__submit(color="primary" :loading="saving" @click="inviteRecipients")
        span(v-if="isScheduled || !poll.notifyRecipients") {{ t('poll_common_form.add_voters') }}
        span(v-else) {{ t('common.action.invite') }}
  .d-flex.flex-wrap.align-center.ga-3.px-4.pt-4(v-if="!someRecipients && canManageWeights")
    v-spacer
    v-btn.poll-members-form__set-all(v-if="canManageWeights" variant="tonal" :disabled="weightsSaving" @click="openSetAllDialog") {{ t('poll_common_form.set_all_vote_weights') }}
  v-list.poll-members-form__list(v-if="!someRecipients" style="flex: 1; min-height: 0; overflow-y: auto")
    v-list-item(v-for="user in users" :key="user.id")
      template(v-slot:prepend)
        user-avatar.mr-2(:user="user" :size="32")
      v-list-item-title
        span.mr-2 {{user.nameWithTitle(poll.group())}}
        v-chip.mr-1(v-if="isDelegate(user)" variant="tonal" size="x-small" label :title="t('members_panel.delegate_popover')")
          | {{ t('members_panel.delegate') }}
        v-chip.mr-1(v-if="isGuest[user.id]" variant="outlined" size="x-small" label :title="t('announcement.inviting_guests_to_discussion')")
          span {{ t('members_panel.guest') }}
        v-chip.mr-1(v-if="isGroupAdmin[user.id] || isTopicAdmin[user.id]" variant="outlined" size="x-small" label)
          span {{ t('members_panel.admin') }}
        v-chip.mr-1(v-if="!user.emailVerified" variant="outlined" size="x-small" label :title="t('announcement.members_list.has_not_joined_yet_hint')")
          span {{ t('announcement.members_list.has_not_joined_yet') }}
      template(v-slot:append)
        v-btn.poll-members-form__weight.mr-1(
          v-if="canManageWeights"
          variant="text"
          size="small"
          :aria-label="t('poll_common_form.edit_vote_weight_for', {name: user.nameOrEmail(), weight: weightsByUserId[user.id]})"
          @click="openWeightDialog(user)")
          span {{ weightsByUserId[user.id] }}
        v-btn.poll-members-form__remove(
          v-if="canRemoveVoters"
          variant="text"
          icon
          size="small"
          :aria-label="t('poll_common_form.remove_voter_named', {name: user.nameOrEmail()})"
          @click="openRemoveDialog(user)")
          common-icon(name="mdi-delete-outline")

    v-list-item(v-if="query && users.length == 0 && !loading")
      v-list-item-title {{ t('discussions_panel.no_results_found', { search: query }) }}
    .d-flex.justify-center(v-if="loading")
      loading
  .d-flex.flex-wrap.align-center.justify-space-between.ga-2.px-4.py-2(v-if="!someRecipients")
    span.poll-members-form__page-count.text-body-small.text-medium-emphasis {{ t('poll_common_form.voter_page_count', {first: pageFirst, last: pageLast, total: voterTotal}) }}
    v-pagination.poll-members-form__pagination(
      v-if="totalPages > 1"
      :model-value="page"
      :length="totalPages"
      :total-visible="7"
      :disabled="loading"
      @update:model-value="changePage")
  v-dialog.poll-members-form__set-all-dialog(v-model="setAllDialog" max-width="480")
    v-card(:title="t('poll_common_form.set_all_vote_weights_title')")
      v-card-text
        p.poll-members-form__set-all-search-note.text-body-small.text-medium-emphasis(v-if="query.trim()") {{ t('poll_common_form.set_all_vote_weights_search_note') }}
        v-radio-group(v-model="weightMode" hide-details)
          v-radio(v-if="canUseMemberWeights" value="membership" :label="t('poll_common_form.set_each_member_default_vote_weight')")
          v-radio(value="value" :label="t('poll_common_form.set_all_vote_weights_the_same')")
        p.text-body-small.text-medium-emphasis(v-if="weightMode === 'membership'") {{ t('poll_common_form.member_vote_weights_hint') }}
        v-text-field.mt-3(
          v-if="weightMode === 'value'"
          v-model="resetWeight"
          type="text"
          inputmode="decimal"
          :label="t('poll_common_form.weight_for_all')"
          :error="!voteWeightValid(resetWeight)")
      v-card-actions
        v-spacer
        v-btn.poll-members-form__set-all-cancel(variant="text" :disabled="weightsSaving" @click="setAllDialog = false") {{ t('common.action.cancel') }}
        v-btn(color="primary" :disabled="weightsSaving || (weightMode === 'value' && !voteWeightValid(resetWeight))" :loading="weightsSaving" @click="resetWeights") {{ t('poll_common_form.set_all') }}
  v-dialog(v-model="weightDialog" max-width="480")
    v-card(:title="t('poll_common_form.edit_vote_weight')")
      v-card-text
        v-text-field.poll-members-form__weight-input(
          v-if="weightUser"
          v-model="weightValue"
          type="text"
          inputmode="decimal"
          :label="t('poll_common_form.vote_weight_for', {name: weightUser.nameOrEmail()})"
          :error="!voteWeightValid(weightValue)"
          @keydown.enter.prevent="saveWeight")
      v-card-actions
        v-spacer
        v-btn(variant="text" :disabled="weightsSaving" @click="weightDialog = false") {{ t('common.action.cancel') }}
        v-btn.poll-members-form__save-weight(color="primary" :disabled="weightsSaving || !voteWeightValid(weightValue)" :loading="weightsSaving" @click="saveWeight") {{ t('common.action.save') }}
  v-dialog.poll-members-form__remove-dialog(v-model="removeDialog" max-width="480")
    v-card(:title="t('poll_common_form.remove_voter')")
      v-card-text(v-if="removeUser") {{ t('poll_common_form.remove_voter_and_any_vote_confirmation', {name: removeUser.nameOrEmail()}) }}
      v-card-actions
        v-spacer
        v-btn.poll-members-form__cancel-remove(variant="text" :disabled="removing" @click="removeDialog = false") {{ t('common.action.cancel') }}
        v-btn.poll-members-form__confirm-remove(color="error" :disabled="removing" :loading="removing" @click="removeVoter") {{ t('poll_common_form.remove_voter') }}
</template>

<style>
.poll-members-form__weight {
  min-width: 56px;
  max-width: 112px;
  border-radius: 999px;
}
</style>
