<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import StanceService from '@/shared/services/stance_service';
import { map, debounce, uniq, compact } from 'lodash-es';

export default {
  components: {
    RecipientsAutocomplete
  },

  props: {
    poll: Object
  },

  data() {
    return {
      users: [],
      userIds: [],
      isMember: {},
      isMemberAdmin: {},
      isStanceAdmin: {},
      reset: false,
      saving: false,
      loading: false,
      initialRecipients: [],
      actionNames: [],
      service: StanceService,
      query: '',
      message: ''
    };
  },

  mounted() {
    this.poll.notifyRecipients = true;
    this.actionNames = ['makeAdmin', 'removeAdmin', 'revoke']; // 'resend'

    this.fetchStances();
    this.updateStances();

    this.watchRecords({
      collections: ['stances', 'memberships', 'users'],
      query: records => this.updateStances()
    });
  },

  computed: {
    wipOrEmpty() { if (this.poll.closingAt) { return ''; } else { return 'wip_'; } },
    someRecipients() {
      return this.poll.recipientAudience ||
      this.poll.recipientUserIds.length ||
      this.poll.recipientEmails.length ||
      this.poll.recipientChatbotIds.length;
    }
  },

  methods: {
    canPerform(action, poll, user) {
      switch (action) {
        case 'makeAdmin':
          return poll.adminsInclude(Session.user()) && !this.isStanceAdmin[user.id] && !this.isMemberAdmin[user.id];
        case 'removeAdmin':
          return poll.adminsInclude(Session.user()) && this.isStanceAdmin[user.id];
        case 'revoke':
          return poll.adminsInclude(Session.user());
      }
    },

    perform(action, poll, user) {
      this.userIds = [];
      this.isMember = {};
      this.isMemberAdmin= {};
      this.isStanceAdmin= {};
      this.service[action].perform(poll, user).then(() => {
        this.fetchStances();
      });
    },

    inviteRecipients() {
      this.saving = true;
      Records.remote.post('announcements', {
        poll_id: this.poll.id,
        recipient_audience: this.poll.recipientAudience,
        recipient_user_ids: this.poll.recipientUserIds,
        recipient_chatbot_ids: this.poll.recipientChatbotIds,
        recipient_emails: this.poll.recipientEmails,
        include_actor: true,
        recipient_message: this.message,
        exclude_members: true,
        notify_recipients: this.poll.notifyRecipients
      }).then(data => {
        const count = data.stances.length;
        if (this.poll.notifyRecipients) {
          Flash.success('announcement.flash.success', { count });
        } else {
          Flash.success('poll_common_form.count_voters_added', { count });
        }

        this.reset = !this.reset;
      }).finally(() => {
        this.saving = false;
      });
    },

    toHash(a) {
      const h = {};
      a.forEach(i => h[i] = true);
      return h;
    },

    newQuery(query) {
      this.query = query;
      this.updateStances();
      this.fetchStances();
    },

    fetchStances: debounce(function() {
      this.loading = true;
      Records.fetch({
        path: 'stances/users',
        params: {
          exclude_types: 'poll group',
          poll_id: this.poll.id,
          query: this.query
      }}).then(data => {
        this.isMember = this.toHash(data['meta']['member_ids']);
        this.isMemberAdmin = this.toHash(data['meta']['member_admin_ids']);
        this.isStanceAdmin = this.toHash(data['meta']['stance_admin_ids']);
        this.userIds = uniq(compact(this.userIds.concat(map(data['users'], 'id'))));
        this.updateStances();
      }).finally(() => {
        this.loading = false;
      });
    } , 300),

    updateStances() {
      let chain = Records.users.collection.chain();
      chain = chain.find({id: {$in: this.userIds}});

      if (this.query) {
        chain = chain.find({
          $or: [
            {name: {'$regex': [`^${this.query}`, "i"]}},
            {email: {'$regex': [`${this.query}`, "i"]}},
            {username: {'$regex': [`^${this.query}`, "i"]}},
            {name: {'$regex': [` ${this.query}`, "i"]}}
          ]});
      }

      this.users = chain.data();
    }
  }
};
</script>

<template>

<div class="poll-members-form">
  <div class="px-4 pt-4">
    <div class="d-flex justify-space-between">
      <h1 class="headline" v-t="'announcement.form.'+wipOrEmpty+'poll_announced.title'"></h1>
      <dismiss-modal-button></dismiss-modal-button>
    </div>
    <recipients-autocomplete :label="poll.notifyRecipients ? $t('announcement.form.'+wipOrEmpty+'poll_announced.helptext') : $t('poll_common_form.who_may_vote', {poll_type: poll.translatedPollType()})" :placeholder="$t('announcement.form.placeholder')" :model="poll" :reset="reset" :excludedAudiences="['voters', 'undecided_voters', 'non_voters', 'decided_voters']" :excludedUserIds="userIds" :initialRecipients="initialRecipients" includeActor="includeActor" :excludeMembers="true" @new-query="newQuery"></recipients-autocomplete>
    <div class="d-flex align-center">
      <v-checkbox :disabled="!someRecipients" :label="$t('poll_common_form.notify_invitees')" v-model="poll.notifyRecipients"></v-checkbox>
      <v-spacer></v-spacer>
      <v-btn class="poll-members-form__submit" color="primary" :disabled="!someRecipients" :loading="saving" @click="inviteRecipients"><span v-t="'common.action.invite'" v-if="poll.notifyRecipients"></span><span v-t="'poll_common_form.add_voters'" v-else></span></v-btn>
    </div>
    <v-alert dense="dense" type="warning" text="text" v-if="someRecipients && !poll.notifyRecipients"><span v-t="'poll_common_form.no_notifications_warning'"></span></v-alert>
    <v-textarea v-if="poll.notifyRecipients && someRecipients" filled="filled" rows="3" v-model="message" :label="$t('announcement.form.invitation_message_label')" :placeholder="$t('announcement.form.invitation_message_placeholder')"></v-textarea>
  </div>
  <v-list class="poll-members-form__list">
    <v-subheader><span v-t="'membership_card.voters'"></span>
      <space></space><span>({{users.length}} / {{poll.votersCount}})</span>
    </v-subheader>
    <v-list-item v-for="user in users" :key="user.id">
      <v-list-item-avatar>
        <user-avatar :user="user" :size="24"></user-avatar>
      </v-list-item-avatar>
      <v-list-item-content>
        <v-list-item-title><span class="mr-2">{{user.nameWithTitle(poll.group())}}</span>
          <v-chip class="mr-1" v-if="!isMember[user.id]" outlined="outlined" x-small="x-small" label="label" v-t="'members_panel.guest'" :title="$t('announcement.inviting_guests_to_thread')"></v-chip>
          <v-chip class="mr-1" v-if="isMemberAdmin[user.id] || isStanceAdmin[user.id]" outlined="outlined" x-small="x-small" label="label" v-t="'members_panel.admin'"></v-chip>
        </v-list-item-title>
      </v-list-item-content>
      <v-list-item-action>
        <v-menu offset-y="offset-y">
          <template v-slot:activator="{on, attrs}">
            <v-btn class="membership-dropdown__button" icon="icon" v-on="on" v-bind="attrs">
              <common-icon name="mdi-dots-vertical"></common-icon>
            </v-btn>
          </template>
          <v-list>
            <v-list-item v-for="action in actionNames" v-if="canPerform(action, poll, user)" @click="perform(action, poll, user)" :key="action">
              <v-list-item-title v-t="{ path: service[action].name, args: { pollType: poll.translatedPollType() } }"></v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>
      </v-list-item-action>
    </v-list-item>
    <v-list-item v-if="query && users.length == 0">
      <v-list-item-title v-t="{ path: 'discussions_panel.no_results_found', args: { search: query }}"></v-list-item-title>
    </v-list-item>
  </v-list>
  <div class="d-flex justify-end mx-4 pb-4">
    <help-link path="en/user_manual/polls/starting_proposals/index.html#invite-members"></help-link>
    <v-spacer></v-spacer>
  </div>
</div>
</template>
