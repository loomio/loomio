<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import StanceService from '@/shared/services/stance_service';
import { map, debounce, uniq, compact } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
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
      isGuest: {},
      isGroupAdmin: {},
      isTopicAdmin: {},
      reset: false,
      saving: false,
      loading: false,
      initialRecipients: [],
      actionNames: [],
      service: StanceService,
      query: '',
      message: '',
      stanceIdsByUserId: {},
      weightsByUserId: {},
      weightsSavedByUserId: {},
      weightsSaving: false
    };
  },

  mounted() {
    this.poll.notifyRecipients = !(this.poll.openingAt && !this.poll.openedAt);
    this.actionNames = this.poll.detachedAnonymousVoting() ? [] : ['revoke'];

    this.fetchStances();
    this.updateStances();

    this.watchRecords({
      collections: ['stances', 'memberships', 'users'],
      query: records => this.updateStances()
    });
  },

  computed: {
    isScheduled() { return this.poll.openingAt && !this.poll.openedAt; },
    wipOrEmpty() { if (this.poll.closingAt) { return ''; } else { return 'wip_'; } },
    someRecipients() {
      return this.poll.recipientAudience ||
      this.poll.recipientUserIds.length ||
      this.poll.recipientEmails.length ||
      this.poll.recipientChatbotIds.length;
    },
    canManageWeights() {
      return this.poll.voteWeightsEnabled && !this.poll.closedAt;
    },
    weightsDirty() {
      return Object.keys(this.weightsByUserId).some(id => Number(this.weightsByUserId[id]) !== Number(this.weightsSavedByUserId[id]));
    },
    weightsValid() {
      return Object.values(this.weightsByUserId).every(weight => Number.isInteger(Number(weight)) && Number(weight) >= 0 && Number(weight) <= 1000000);
    }
  },

  methods: {
    isDelegate(user) {
      const group = this.poll.group();
      return Boolean(group && user.delegates && user.delegates[group.id]);
    },
    performableActions(poll, user) {
      return this.actionNames.filter(name => this.canPerform(name, poll, user))
    },
    saveWeights() {
      const weights = {};
      Object.keys(this.weightsByUserId).forEach(userId => {
        weights[this.stanceIdsByUserId[userId]] = this.weightsByUserId[userId];
      });

      this.weightsSaving = true;
      Records.remote.patch('stances/set_weights', {poll_id: this.poll.id, weights}).then(() => {
        this.weightsSavedByUserId = Object.assign({}, this.weightsByUserId);
        Flash.success('poll_common_form.vote_weights_updated');
      }).catch(error => {
        Flash.fromServer(error);
      }).finally(() => {
        this.weightsSaving = false;
      });
    },
    canPerform(action, poll, user) {
      switch (action) {
        case 'revoke':
          return poll.adminsInclude(Session.user());
      }
    },

    perform(action, poll, user) {
      this.userIds = [];
      this.isMember = {};
      this.isGroupAdmin= {};
      this.isTopicAdmin= {};
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
        const count = (data.stances || data.users).length;
        if (this.poll.notifyRecipients) {
          Flash.success('announcement.flash.success', { count });
        } else {
          Flash.success('poll_common_form.count_voters_added', { count });
        }
        this.fetchStances()

        this.reset = !this.reset;
      }).catch(error => {
        Flash.fromServer(error.flash || error);
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
        this.isGuest = this.toHash(data['meta']['guest_ids']);
        this.isGroupAdmin = this.toHash(data['meta']['group_admin_ids']);
        this.isTopicAdmin = this.toHash(data['meta']['topic_admin_ids']);
        if (this.canManageWeights) {
          this.stanceIdsByUserId = data.meta.stance_ids_by_user_id || {};
          this.weightsByUserId = Object.fromEntries(Object.entries(data.meta.weights_by_user_id || {}).map(([id, weight]) => [id, Number(weight)]));
          this.weightsSavedByUserId = Object.assign({}, this.weightsByUserId);
        }
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

<template lang="pug">
v-card.poll-members-form
  .px-4.pt-4
    .d-flex.justify-space-between
      //- template(v-if="poll.notifyRecipients")
      h1.text-headline-small(v-t="'announcement.form.'+wipOrEmpty+'poll_announced.title'")
      //- h1.text-headline-small(v-if="!poll.closingAt" v-t="'announcement.form.wip_poll_announced.title'")
      //- h1.text-headline-small(v-else v-t="'poll_common_form.add_voters'")
      dismiss-modal-button
    recipients-autocomplete(
      :label="poll.notifyRecipients ? $t('announcement.form.'+wipOrEmpty+'poll_announced.helptext') : $t('poll_common_form.who_may_vote', {poll_type: poll.translatedPollType()})"
      :placeholder="$t('announcement.form.placeholder')"
      :model="poll"
      :reset="reset"
      :excludedAudiences="['voters', 'undecided_voters', 'non_voters', 'decided_voters']"
      :excludedUserIds="userIds"
      :initialRecipients="initialRecipients"
      includeActor
      :excludeMembers="true"
      @new-query="newQuery")

    .d-flex.align-center(v-if="!isScheduled")
      v-checkbox(:disabled="!someRecipients" :label="$t('poll_common_form.notify_invitees')" v-model="poll.notifyRecipients")
      v-spacer
      v-btn.poll-members-form__submit(color="primary" :disabled="!someRecipients" :loading="saving" @click="inviteRecipients" )
        span(v-t="'common.action.invite'" v-if="poll.notifyRecipients")
        span(v-t="'poll_common_form.add_voters'" v-else)
    .d-flex.align-center(v-if="isScheduled")
      v-spacer
      v-btn.poll-members-form__submit(color="primary" :disabled="!someRecipients" :loading="saving" @click="inviteRecipients" )
        span(v-t="'poll_common_form.add_voters'")
    v-alert(density="compact" type="info" text v-if="isScheduled && someRecipients")
      span(v-t="'poll_common_form.voters_notified_when_opens'")
    v-alert(density="compact" type="warning" text v-if="!isScheduled && someRecipients && !poll.notifyRecipients")
      span(v-t="'poll_common_form.no_notifications_warning'")
    v-textarea(v-if="!isScheduled && poll.notifyRecipients && someRecipients" filled rows="3" v-model="message" :label="$t('announcement.form.invitation_message_label')" :placeholder="$t('announcement.form.invitation_message_placeholder')")
    v-alert.mt-2(v-if="canManageWeights" density="compact" type="info" variant="tonal")
      span(v-t="'poll_common_form.vote_weight_helptext'")
  v-list.poll-members-form__list
    v-list-subheader
      span(v-t="'membership_card.voters'")
      space
      span ({{users.length}} / {{poll.votersCount}})
    v-list-item(v-for="user in users" :key="user.id")
      template(v-slot:prepend)
        user-avatar.mr-2(:user="user" :size="32")
      v-list-item-title
        span.mr-2 {{user.nameWithTitle(poll.group())}}
        v-chip.mr-1(v-if="isDelegate(user)" variant="tonal" size="x-small" label :title="$t('members_panel.delegate_popover')")
          | {{ $t('members_panel.delegate') }}
        v-chip.mr-1(v-if="isGuest[user.id]" variant="outlined" size="x-small" label :title="$t('announcement.inviting_guests_to_discussion')")
          span(v-t="'members_panel.guest'")
        v-chip.mr-1(v-if="isGroupAdmin[user.id] || isTopicAdmin[user.id]" variant="outlined" size="x-small" label)
          span(v-t="'members_panel.admin'")
        v-chip.mr-1(v-if="!user.emailVerified" variant="outlined" size="x-small" label :title="$t('announcement.members_list.has_not_joined_yet_hint')")
          span(v-t="'announcement.members_list.has_not_joined_yet'")
      template(v-slot:append)
        v-text-field.poll-members-form__weight.mr-2(
          v-if="canManageWeights"
          v-model.number="weightsByUserId[user.id]"
          type="number"
          min="0"
          max="1000000"
          step="1"
          density="compact"
          hide-details
          :aria-label="$t('poll_common_form.vote_weight_for', {name: user.name})")
        v-menu(offset-y)
          template(v-slot:activator="{ props }")
            v-btn.membership-dropdown__button(variant="flat" icon size="small" v-bind="props")
              common-icon(name="mdi-dots-vertical")
          v-list
            v-list-item(
              v-for="action in performableActions(poll, user)"
              @click="perform(action, poll, user)"
              :key="action")
              v-list-item-title(v-t="{ path: service[action].name, args: { pollType: poll.translatedPollType() } }")

    v-list-item(v-if="query && users.length == 0")
      v-list-item-title(v-t="{ path: 'discussions_panel.no_results_found', args: { search: query }}")
  .d-flex.justify-end.mx-4.pb-4
    v-btn(v-if="canManageWeights" color="primary" :disabled="!weightsDirty || !weightsValid" :loading="weightsSaving" @click="saveWeights")
      span(v-t="'poll_common_form.save_vote_weights'")
    help-btn(
      path="en/user_manual/polls/inviting_people#add-voters-to-the-poll")
    v-spacer
</template>

<style>
.poll-members-form__weight {
  max-width: 112px;
}
</style>
