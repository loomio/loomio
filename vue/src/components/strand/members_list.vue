<script setup>
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import TopicReaderService from '@/shared/services/topic_reader_service';
import {map, debounce} from 'lodash-es';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { approximate } from '@/shared/helpers/format_time';
import { ref, computed } from 'vue';

const props = defineProps({
  topic: Object
});

const discussion = computed(() => props.topic.discussion());
const group = computed(() => props.topic.group());

const readers = ref([]);
const query = ref('');
const recipients = ref([]);
const membershipsByUserId = ref({});
const readerUserIds = ref([]);
const reset = ref(false);
const saving = ref(false);
const message = ref('');
const actionNames = ['makeAdmin', 'removeAdmin', 'revoke'];
const service = TopicReaderService;

const hasRecipients = computed(() => {
  return discussion.value &&
    (discussion.value.recipientAudience ||
    discussion.value.recipientUserIds.length ||
    discussion.value.recipientChatbotIds.length ||
    discussion.value.recipientEmails.length);
});

const excludedUserIds = computed(() => {
  return readerUserIds.value.concat(Session.user().id);
});

function approximateDate(date) { return approximate(date); }

function performableActions(reader) {
  return actionNames.filter((action) => service[action].canPerform(reader));
}

function isGroupAdmin(reader) {
  return group.value &&
    membershipsByUserId.value[reader.userId] &&
    membershipsByUserId.value[reader.userId].admin;
}

function inviteRecipients() {
  const count = recipients.value.length;
  saving.value = true;
  const params = {
    discussion_id: discussion.value.id,
    recipient_audience: discussion.value.recipientAudience,
    recipient_user_ids: discussion.value.recipientUserIds,
    recipient_chatbot_ids: discussion.value.recipientChatbotIds,
    recipient_emails: discussion.value.recipientEmails,
    recipient_message: message.value
  };
  Records.remote.post('announcements', params).then(() => {
    reset.value = !reset.value;
    Flash.success('announcement.flash.success', { count });
  }).catch(error => {
    Flash.custom(error.error, 'error', 5000);
  }).finally(() => {
    saving.value = false;
  });
}

function newQuery(q) {
  query.value = q;
  updateReaders();
  fetchReaders();
}

function newRecipients(r) { recipients.value = r; }

const fetchReaders = debounce(function() {
  Records.topicReaders.fetch({
    params: {
      query: query.value,
      discussion_id: discussion.value.id
    }
  }).then(records => {
    const userIds = map(records['users'], 'id');
    if (group.value) {
      Records.memberships.fetch({
        params: {
          exclude_types: 'group inviter',
          group_id: group.value.id,
          user_xids: userIds.join('x')
        }
      });
    }
  }).finally(() => updateReaders());
} , 300);

function updateReaders() {
  let chain = Records.topicReaders.collection.chain().
          find({topicId: props.topic.id}).
          find({revokedAt: null});

  if (query.value) {
    const users = Records.users.collection.find({
      $or: [
        {name: {'$regex': [`^${query.value}`, "i"]}},
        {email: {'$regex': [`${query.value}`, "i"]}},
        {username: {'$regex': [`^${query.value}`, "i"]}},
        {name: {'$regex': [` ${query.value}`, "i"]}}
      ]});
    chain = chain.find({userId: {$in: map(users, 'id')}});
  }

  chain = chain.simplesort('id', true);
  readers.value = chain.data();
  readerUserIds.value = map(Records.topicReaders.collection.find({topicId: props.topic.id}), 'userId');

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
  collections: ['topicReaders', 'memberships'],
  query: () => updateReaders()
});
</script>

<template lang="pug">
v-card.strand-members-list(:title="$t('announcement.form.discussion_announced.title')")
  template(v-slot:append)
    dismiss-modal-button

  v-card-text
    recipients-autocomplete(
      :label="$t('announcement.form.discussion_announced.helptext')"
      :placeholder="$t('announcement.form.placeholder')"
      :model="discussion"
      :excluded-audiences="['discussion_group']"
      :reset="reset"
      @new-query="newQuery"
      @new-recipients="newRecipients")

    v-textarea(
      v-if="hasRecipients"
      filled
      rows="3"
      v-model="message"
      :label="$t('announcement.form.invitation_message_label')"
      :placeholder="$t('announcement.form.invitation_message_placeholder')"
    )

    .d-flex
      v-spacer
      v-btn.strand-members-list__submit(
        color="primary"
        :disabled="!recipients.length"
        :loading="saving"
        @click="inviteRecipients"
        v-t="'common.action.invite'")

  v-list.px-2(lines="two")
    v-list-subheader
      span(v-t="'membership_card.discussion_members'")
      space
      span ({{topic.membersCount}})
    v-list-item(v-for="reader in readers" :user="reader.user()" :key="reader.id")
      template(v-slot:prepend)
        user-avatar.mr-2(:user="reader.user()" :size="32")
      v-list-item-title
        span.mr-2 {{reader.user().nameWithTitle(group)}}
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
            v-list-item(v-for="action in performableActions(reader)" @click="service[action].perform(reader)" :key="action")
              v-list-item-title(v-t="service[action].name")
    v-list-item(v-if="query && readers.length == 0")
      v-list-item-title(v-t="{ path: 'discussions_panel.no_results_found', args: { search: query }}")
</template>
