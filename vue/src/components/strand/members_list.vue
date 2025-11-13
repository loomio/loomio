<script setup lang="js">
import { ref, computed, onMounted } from 'vue';
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import DiscussionReaderService from '@/shared/services/discussion_reader_service';
import { map, debounce } from 'lodash-es';
import { useWatchRecords } from '@/shared/composables/use_watch_records';
import { useFormatDate } from '@/shared/composables/use_format_date';

const props = defineProps({
  discussion: Object
});

const readers = ref([]);
const query = ref('');
const searchResults = ref([]);
const recipients = ref([]);
const membershipsByUserId = ref({});
const readerUserIds = ref([]);
const reset = ref(false);
const saving = ref(false);
const message = ref('');
const actionNames = ref([]);
const service = DiscussionReaderService;
const { watchRecords } = useWatchRecords();
const { approximateDate } = useFormatDate();

const hasRecipients = computed(() => {
  return props.discussion.recipientAudience ||
    props.discussion.recipientUserIds.length ||
    props.discussion.recipientChatbotIds.length ||
    props.discussion.recipientEmails.length;
});

const model = computed(() => props.discussion);

const excludedUserIds = computed(() => {
  return readerUserIds.value.concat(Session.user().id);
});

const performableActions = (reader) => {
  return actionNames.value.filter((action) => service[action].canPerform(reader));
};

const isGroupAdmin = (reader) => {
  return props.discussion.groupId &&
    membershipsByUserId.value[reader.userId] &&
    membershipsByUserId.value[reader.userId].admin;
};

const inviteRecipients = () => {
  const count = recipients.value.length;
  saving.value = true;
  const params = Object.assign(
    { discussion_id: props.discussion.id },
    {
      recipient_audience: props.discussion.recipientAudience,
      recipient_user_ids: props.discussion.recipientUserIds,
      recipient_chatbot_ids: props.discussion.recipientChatbotIds,
      recipient_emails: props.discussion.recipientEmails,
      recipient_message: message.value
    }
  );
  Records.remote.post('announcements', params).then(() => {
    reset.value = !reset.value;
    Flash.success('announcement.flash.success', { count });
  }).catch(error => {
    Flash.custom(error.error, 'error', 5000);
  }).finally(() => {
    saving.value = false;
  });
};

const newQuery = (q) => {
  query.value = q;
  updateReaders();
  fetchReaders();
};

const newRecipients = (newRecips) => {
  recipients.value = newRecips;
};

const fetchReaders = debounce(function() {
  Records.discussionReaders.fetch({
    params: {
      exclude_types: 'discussion',
      query: query.value,
      discussion_id: props.discussion.id
    }
  }).then(records => {
    const userIds = map(records['users'], 'id');
    Records.memberships.fetch({
      params: {
        exclude_types: 'group inviter',
        group_id: props.discussion.groupId,
        user_xids: userIds.join('x')
      }
    });
  }).finally(() => updateReaders());
}, 300);

const updateReaders = () => {
  let chain = Records.discussionReaders.collection.chain().
    find({ discussionId: props.discussion.id }).
    find({ revokedAt: null });

  if (query.value) {
    const users = Records.users.collection.find({
      $or: [
        { name: { '$regex': [`^${query.value}`, "i"] } },
        { email: { '$regex': [`${query.value}`, "i"] } },
        { username: { '$regex': [`^${query.value}`, "i"] } },
        { name: { '$regex': [` ${query.value}`, "i"] } }
      ]
    });
    chain = chain.find({ userId: { $in: map(users, 'id') } });
  }

  chain = chain.simplesort('id', true);
  readers.value = chain.data();
  readerUserIds.value = map(Records.discussionReaders.collection.find({ discussionId: props.discussion.id }), 'userId');

  membershipsByUserId.value = {};
  Records.memberships.collection.find({
    userId: { $in: readerUserIds.value },
    groupId: props.discussion.groupId
  }).forEach(m => {
    membershipsByUserId.value[m.userId] = m;
  });
};

onMounted(() => {
  actionNames.value = ['makeAdmin', 'removeAdmin', 'revoke']; // 'resend'

  fetchReaders();
  
  watchRecords({
    collections: ['discussionReaders', 'memberships'],
    query: records => updateReaders()
  });
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
      span ({{discussion.membersCount}})
    v-list-item(v-for="reader in readers" :user="reader.user()" :key="reader.id")
      template(v-slot:prepend)
        user-avatar.mr-2(:user="reader.user()" :size="32")
      v-list-item-title
        span.mr-2 {{reader.user().nameWithTitle(discussion.group())}}
        v-chip.mr-1(v-if="discussion.groupId && reader.guest" variant="tonal" size="x-small" :title="$t('announcement.inviting_guests_to_thread')")
          span(v-t="'members_panel.guest'")
        v-chip.mr-1(v-if="reader.admin" variant="tonal" size="x-small")
          span(v-t="'announcement.members_list.thread_admin'")
        v-chip.mr-1(v-if="isGroupAdmin(reader)" variant="tonal" size="x-small")
          span(v-t="'announcement.members_list.group_admin'")
        v-chip.mr-1(v-if="!reader.user().emailVerified" variant="tonal" size="x-small" :title="$t('announcement.members_list.has_not_joined_yet_hint')")
          span(v-t="'announcement.members_list.has_not_joined_yet'")
      v-list-item-subtitle
        span(v-if="reader.lastReadAt" v-t="{ path: 'announcement.members_list.last_read_at', args: { time: approximateDate(reader.lastReadAt) } }")
        span(v-else v-t="'announcement.members_list.has_not_read_thread'")
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