<script setup>
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import Flash from '@/shared/services/flash';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import TopicReaderService from '@/shared/services/topic_reader_service';
import {debounce} from 'lodash-es';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { approximate } from '@/shared/helpers/format_time';
import { useI18n } from 'vue-i18n';
import { ref, computed } from 'vue';

const { t } = useI18n();
const { topic } = defineProps({
  topic: Object
});

const group = computed(() => topic.group());
const canAddGuests = computed(() => AbilityService.canAddGuestsTopic(topic));
const hasSpecifiedVotersOnlyPolls = computed(() =>
  Records.polls.collection.find({topicId: topic.id, specifiedVotersOnly: true}).length > 0
);

const readers = ref([]);
const readerIds = ref([]);
const readerTotal = ref(0);
const page = ref(1);
const per = 50;
const loading = ref(false);
let fetchSequence = 0;
const query = ref('');
const recipients = ref([]);
const membershipsByUserId = ref({});
const readerUserIds = ref([]);
const reset = ref(false);
const saving = ref(false);
const message = ref('');
const groupInfoDismissed = ref(Session.user().hasExperienced('dismissThreadMembersGroupInfo'));
const voterInfoDismissed = ref(Session.user().hasExperienced('dismissThreadMembersVoterInfo'));
const actionNames = ['makeAdmin', 'removeAdmin', 'revoke'];
const service = TopicReaderService;

const hasRecipients = computed(() => {
  return topic.recipientAudience ||
    topic.recipientUserIds.length ||
    topic.recipientChatbotIds.length ||
    topic.recipientEmails.length;
});
const totalPages = computed(() => Math.max(1, Math.ceil(readerTotal.value / per)));
const pageFirst = computed(() => readerTotal.value ? (page.value - 1) * per + 1 : 0);
const pageLast = computed(() => Math.min(page.value * per, readerTotal.value));

function approximateDate(date) { return approximate(date); }

function dismissGroupInfo() {
  groupInfoDismissed.value = true;
  Records.users.saveExperience('dismissThreadMembersGroupInfo');
}

function dismissVoterInfo() {
  voterInfoDismissed.value = true;
  Records.users.saveExperience('dismissThreadMembersVoterInfo');
}

function performableActions(reader) {
  return actionNames.filter((action) => service[action].canPerform(reader));
}

function performReaderAction(action, reader) {
  service[action].perform(reader).then(() => {
    if (action === 'revoke') fetchReaders();
  }).catch(error => Flash.fromServer(error));
}

function isGroupAdmin(reader) {
  return group.value &&
    membershipsByUserId.value[reader.userId] &&
    membershipsByUserId.value[reader.userId].admin;
}

function isDelegate(reader) {
  return group.value &&
    membershipsByUserId.value[reader.userId] &&
    membershipsByUserId.value[reader.userId].delegate;
}

function inviteRecipients() {
  const count = recipients.value.length;
  saving.value = true;
  const params = {
    topic_id: topic.id,
    recipient_audience: topic.recipientAudience,
    recipient_user_ids: topic.recipientUserIds,
    recipient_chatbot_ids: topic.recipientChatbotIds,
    recipient_emails: topic.recipientEmails,
    recipient_message: message.value
  };
  Records.remote.post('announcements', params).then(() => {
    reset.value = !reset.value;
    page.value = 1;
    fetchReaders();
    Flash.success('announcement.flash.success', { count });
  }).catch(error => {
    Flash.fromServer(error.flash || error);
  }).finally(() => {
    saving.value = false;
  });
}

function newQuery(q) {
  if (query.value === q) return;
  query.value = q;
  page.value = 1;
  readerIds.value = [];
  readerTotal.value = 0;
  readers.value = [];
  loading.value = true;
  fetchReaders();
}

function changePage(nextPage) {
  page.value = nextPage;
  readerIds.value = [];
  readers.value = [];
  loading.value = true;
  fetchReaders();
}

function newRecipients(r) { recipients.value = r; }

// Keep the server's filtered page and count together; ignore responses from an older search or page.
const fetchReaders = debounce(function() {
  const currentQuery = query.value;
  const currentPage = page.value;
  const sequence = ++fetchSequence;
  loading.value = true;
  Records.topicReaders.fetch({
    params: {
      query: currentQuery,
      topic_id: topic.id,
      active_only: 1,
      from: (currentPage - 1) * per,
      per
    }
  }).then(data => {
    if (sequence !== fetchSequence || currentQuery !== query.value || currentPage !== page.value) return;
    readerTotal.value = data.meta.total;
    if (page.value > totalPages.value) {
      changePage(totalPages.value);
      return;
    }
    readerIds.value = data.topic_readers.map(reader => reader.id);
    updateReaders();
    const userIds = readers.value.map(reader => reader.userId);
    if (group.value) {
      Records.memberships.fetch({
        params: {
          exclude_types: 'group inviter',
          group_id: group.value.id,
          user_xids: userIds.join('x')
        }
      });
    }
  }).catch(error => Flash.fromServer(error)).finally(() => {
    if (sequence === fetchSequence && currentQuery === query.value && currentPage === page.value) loading.value = false;
  });
} , 300);

function updateReaders() {
  readers.value = readerIds.value.map(id => Records.topicReaders.findById(id)).filter(reader => reader && !reader.revokedAt);
  readerUserIds.value = readers.value.map(reader => reader.userId);

  membershipsByUserId.value = {};
  if (group.value) {
    Records.memberships.collection.find({userId: {$in: readerUserIds.value},
                                         groupId: group.value.id}).forEach(m => {
      membershipsByUserId.value[m.userId] = m;
    });
  }
}

// init
fetchReaders();

const { watchRecords } = useWatchRecords();
watchRecords({
  collections: ['topicReaders', 'memberships', 'polls'],
  query: () => updateReaders()
});
</script>

<template lang="pug">
v-card.topic-members-list(:title="t('strand_members_list.manage_thread_members')" style="height: 760px; max-height: 90vh; flex: none; display: flex; flex-direction: column; overflow-y: auto")
  template(v-slot:append)
    help-btn.text-medium-emphasis.mr-2(path="en/user_manual/discussions/using_discussions#invite-people" label="common.user_manual" variant="text")
    dismiss-modal-button

  v-card-text(style="flex: none")
    v-alert.mb-2(v-if="group && canAddGuests && !groupInfoDismissed" type="info" variant="tonal" density="compact" closable @click:close="dismissGroupInfo")
      span {{ t('strand_members_list.guest_access_info') }}
    v-alert.mb-2(v-if="hasSpecifiedVotersOnlyPolls && !voterInfoDismissed" type="warning" variant="tonal" density="compact" closable @click:close="dismissVoterInfo")
      span(v-t="'strand_members_list.specified_voters_only_warning'")

    recipients-autocomplete(
      :label="t('strand_members_list.find_or_invite_people')"
      :placeholder="$t('announcement.form.placeholder')"
      :model="topic"
      :excluded-audiences="['topic']"
      :reset="reset"
      hideEmptyResults
      preserveSearchOnBlur
      @update:search="newQuery"
      @new-recipients="newRecipients")

    p.text-body-small.text-medium-emphasis.mt-2(v-if="hasRecipients") {{ t('strand_members_list.invite_or_notify_explanation') }}

    v-textarea(
      v-if="hasRecipients"
      filled
      rows="3"
      v-model="message"
      :label="$t('announcement.form.invitation_message_label')"
      :placeholder="$t('announcement.form.invitation_message_placeholder')"
    )

    .d-flex(v-if="hasRecipients")
      v-spacer
      v-btn.topic-members-list__submit(
        color="primary"
        :disabled="!recipients.length"
        :loading="saving"
        @click="inviteRecipients") {{ t('strand_members_list.invite_or_notify') }}

  v-list.topic-members-list__readers.px-2(v-if="!hasRecipients" lines="two" density="compact" style="flex: 1; min-height: 0; overflow-y: auto")
    v-list-item(v-for="reader in readers" :user="reader.user()" :key="reader.id")
      template(v-slot:prepend)
        user-avatar.mr-2(:user="reader.user()" :size="32")
      v-list-item-title
        span.mr-2 {{reader.user().nameWithTitle(group)}}
        v-chip.mr-1(v-if="isDelegate(reader)" variant="tonal" size="x-small" label :title="$t('members_panel.delegate_popover')")
          | {{ $t('members_panel.delegate') }}
        v-chip.mr-1(v-if="group && reader.guest" variant="tonal" size="x-small" :title="$t('announcement.inviting_guests_to_discussion')")
          span(v-t="'members_panel.guest'")
        v-chip.mr-1(v-if="reader.admin" variant="tonal" size="x-small")
          span(v-t="'announcement.members_list.thread_admin'")
        v-chip.mr-1(v-if="isGroupAdmin(reader)" variant="tonal" size="x-small")
          span(v-t="'announcement.members_list.group_admin'")
        v-chip.mr-1(v-if="!reader.user().emailVerified" variant="tonal" size="x-small" :title="$t('announcement.members_list.has_not_joined_yet_hint')")
          span(v-t="'announcement.members_list.has_not_joined_yet'")
      v-list-item-subtitle
        span(v-if="reader.lastReadAt" v-t="{ path: 'announcement.members_list.last_read_at', args: { time: approximateDate(reader.lastReadAt) } }")
        span(v-else v-t="'announcement.members_list.has_not_read_discussion'")
      template(v-slot:append)
        v-menu(
          v-if="performableActions(reader).length > 0"
          offset-y
        )
          template(v-slot:activator="{props}")
            v-btn.membership-dropdown__button(variant="flat" icon v-bind="props")
              common-icon(name="mdi-dots-vertical")
          v-list
            v-list-item(v-for="action in performableActions(reader)" @click="performReaderAction(action, reader)" :key="action")
              v-list-item-title {{ t(service[action].name) }}
    v-list-item(v-if="query && readers.length == 0 && !loading")
      v-list-item-title {{ t('discussions_panel.no_results_found', { search: query }) }}
    .d-flex.justify-center(v-if="loading")
      loading
  .d-flex.flex-wrap.align-center.justify-space-between.ga-2.px-4.py-2(v-if="!hasRecipients")
    span.topic-members-list__page-count.text-body-small.text-medium-emphasis {{ t('strand_members_list.member_page_count', {first: pageFirst, last: pageLast, total: readerTotal}) }}
    v-pagination.topic-members-list__pagination(
      v-if="totalPages > 1"
      :model-value="page"
      :length="totalPages"
      :total-visible="7"
      :disabled="loading"
      @update:model-value="changePage")
</template>
