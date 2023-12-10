<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import DiscussionReaderService from '@/shared/services/discussion_reader_service';
import {map, debounce} from 'lodash-es';

export default {
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
    isGroupAdmin(reader) {
      return this.discussion.groupId && 
      this.membershipsByUserId[reader.userId] &&
      this.membershipsByUserId[reader.userId].admin;
    },

    isGuest(reader) {
      return !this.membershipsByUserId[reader.userId];
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
      Records.memberships.collection.find({userId: {$in: this.readerUserIds}},
                                          {groupId: this.discussion.groupId}).forEach(m => {
        this.membershipsByUserId[m.userId] = m;
      });
    }
  }
};

</script>

<template lang="pug">
.strand-members-list
  .px-4.pt-4
    .d-flex.justify-space-between
      h1.text-h5(v-t="'announcement.form.discussion_announced.title'")
      dismiss-modal-button

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

  v-list(two-line)
    v-subheader
      span(v-t="'membership_card.discussion_members'")
      space
      span ({{discussion.membersCount}})
    v-list-item(v-for="reader in readers" :user="reader.user()" :key="reader.id")
      v-list-item-avatar
        user-avatar(:user="reader.user()" :size="24")
      v-list-item-content
        v-list-item-title
          span.mr-2 {{reader.user().nameWithTitle(discussion.group())}}
          v-chip.mr-1(v-if="discussion.groupId && isGuest(reader)" outlined x-small label v-t="'members_panel.guest'" :title="$t('announcement.inviting_guests_to_thread')")
          v-chip.mr-1(v-if="reader.admin" outlined x-small label v-t="'announcement.members_list.thread_admin'")
          v-chip.mr-1(v-if="isGroupAdmin(reader)" outlined x-small label v-t="'announcement.members_list.group_admin'")
        v-list-item-subtitle
          span(v-if="reader.lastReadAt" v-t="{ path: 'announcement.members_list.last_read_at', args: { time: approximateDate(reader.lastReadAt) } }")
          span(v-else v-t="'announcement.members_list.has_not_read_thread'")
          //- time-ago(:date="reader.lastReadAt")
      v-list-item-action
        v-menu(offset-y)
          template(v-slot:activator="{on, attrs}")
            v-btn.membership-dropdown__button(icon v-on="on" v-bind="attrs")
              common-icon(name="mdi-dots-vertical")
          v-list
            v-list-item(v-for="action in actionNames" v-if="service[action].canPerform(reader)" @click="service[action].perform(reader)" :key="action")
              v-list-item-title(v-t="service[action].name")
    v-list-item(v-if="query && readers.length == 0")
      v-list-item-title(v-t="{ path: 'discussions_panel.no_results_found', args: { search: query }}")
</template>
