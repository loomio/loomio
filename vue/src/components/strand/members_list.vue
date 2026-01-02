<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import DiscussionReaderService from '@/shared/services/discussion_reader_service';
import {map, debounce} from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';
import FormatDate from '@/mixins/format_date';

export default {
  mixins: [WatchRecords, FormatDate],
  components: {
    RecipientsAutocomplete
  },

  props: {
    discussion: Object
  },

  data() {
    return {
      readers: [],
      query: '',
      searchResults: [],
      recipients: [],
      membershipsByUserId: {},
      readerUserIds: [],
      reset: false,
      saving: false,
      message: '',
      actionNames: [],
      service: DiscussionReaderService
    };
  },

  mounted() {
    this.actionNames = ['makeAdmin', 'removeAdmin', 'revoke']; // 'resend'

    this.fetchReaders();
    this.watchRecords({
      collections: ['discussionReaders', 'memberships'],
      query: records => this.updateReaders()
    });
  },

  computed: {
    hasRecipients() {
      return this.discussion.recipientAudience ||
      this.discussion.recipientUserIds.length ||
      this.discussion.recipientChatbotIds.length ||
      this.discussion.recipientEmails.length;
    },

    model() { return this.discussion; },

    excludedUserIds() {
      return this.readerUserIds.concat(Session.user().id);
    }
  },

  methods: {
    performableActions(reader) {
      return this.actionNames.filter((action) => this.service[action].canPerform(reader))
    },

    isGroupAdmin(reader) {
      return this.discussion.groupId &&
      this.membershipsByUserId[reader.userId] &&
      this.membershipsByUserId[reader.userId].admin;
    },

    inviteRecipients() {
      const count = this.recipients.length;
      this.saving = true;
      const params = Object.assign(
        {discussion_id: this.discussion.id}
      , {
        recipient_audience: this.discussion.recipientAudience,
        recipient_user_ids: this.discussion.recipientUserIds,
        recipient_chatbot_ids: this.discussion.recipientChatbotIds,
        recipient_emails: this.discussion.recipientEmails,
        recipient_message: this.message
      }
      );
      Records.remote.post('announcements', params).then(() => {
        this.reset = !this.reset;
        Flash.success('announcement.flash.success', { count });
      }).catch(error => {
        Flash.custom(error.error, 'error', 5000);
      }).finally(() => {
        this.saving = false;
      });
    },

    newQuery(query) {
      this.query = query;
      this.updateReaders();
      this.fetchReaders();
    },

    newRecipients(recipients) { this.recipients = recipients; },

    fetchReaders: debounce(function() {
      Records.discussionReaders.fetch({
        params: {
          exclude_types: 'discussion',
          query: this.query,
          discussion_id: this.discussion.id
        }
      }).then(records => {
        const userIds = map(records['users'], 'id');
        Records.memberships.fetch({
          params: {
            exclude_types: 'group inviter',
            group_id: this.discussion.groupId,
            user_xids: userIds.join('x')
          }
        });
      }).finally(() => this.updateReaders());
    } , 300),

    updateReaders() {
      let chain = Records.discussionReaders.collection.chain().
              find({discussionId: this.discussion.id}).
              find({revokedAt: null});

      if (this.query) {
        const users = Records.users.collection.find({
          $or: [
            {name: {'$regex': [`^${this.query}`, "i"]}},
            {email: {'$regex': [`${this.query}`, "i"]}},
            {username: {'$regex': [`^${this.query}`, "i"]}},
            {name: {'$regex': [` ${this.query}`, "i"]}}
          ]});
        chain = chain.find({userId: {$in: map(users, 'id')}});
      }

      chain = chain.simplesort('id', true);
      this.readers = chain.data();
      this.readerUserIds = map(Records.discussionReaders.collection.find({discussionId: this.discussion.id}), 'userId');

      this.membershipsByUserId = {};
      Records.memberships.collection.find({userId: {$in: this.readerUserIds},
                                           groupId: this.discussion.groupId}).forEach(m => {
        this.membershipsByUserId[m.userId] = m;
      });
    }
  }
};

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
        v-chip.mr-1(v-if="discussion.groupId && reader.guest" variant="tonal" size="x-small" :title="$t('announcement.inviting_guests_to_discussion')")
          span(v-t="'members_panel.guest'")
        v-chip.mr-1(v-if="reader.admin" variant="tonal" size="x-small")
          span(v-t="'announcement.members_list.discussion_admin'")
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
