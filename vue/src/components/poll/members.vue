<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import StanceService from '@/shared/services/stance_service';
import { map, debounce } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';
import { useI18n } from 'vue-i18n';
import { voteWeightValid } from '@/shared/helpers/vote_weight';

export default {
  setup() {
    const { t } = useI18n();
    return { t };
  },
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
      weightsSaving: false,
      resetWeight: '1',
      weightMode: 'membership',
      setAllDialog: false,
      voterTotal: 0,
      page: 1,
      per: 20,
      fetchSequence: 0
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
      return this.poll.voteWeightsEnabled && !this.poll.closedAt && this.poll.adminsInclude(Session.user());
    },
    weightsDirty() {
      return Object.keys(this.weightsByUserId).some(id => Number(this.weightsByUserId[id]) !== Number(this.weightsSavedByUserId[id]));
    },
    weightsValid() {
      return Object.values(this.weightsByUserId).every(voteWeightValid);
    },
    canUseMemberWeights() { return Boolean(this.poll.groupId); },
    totalPages() { return Math.max(1, Math.ceil(this.voterTotal / this.per)); },
    pageFirst() { return this.voterTotal ? (this.page - 1) * this.per + 1 : 0; },
    pageLast() { return Math.min(this.page * this.per, this.voterTotal); }
  },

  methods: {
    voteWeightValid,
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
        if (Number(this.weightsByUserId[userId]) !== Number(this.weightsSavedByUserId[userId])) {
          weights[this.stanceIdsByUserId[userId]] = this.weightsByUserId[userId];
        }
      });

      this.weightsSaving = true;
      Records.remote.patch('stances/set_weights', {poll_id: this.poll.id, weights}).then(() => Records.polls.remote.fetchById(this.poll.id)).then(() => {
        this.weightsSavedByUserId = Object.assign({}, this.weightsByUserId);
        Flash.success('poll_common_form.vote_weights_updated');
      }).catch(error => {
        Flash.fromServer(error);
      }).finally(() => {
        this.weightsSaving = false;
      });
    },
    openSetAllDialog() {
      this.weightMode = this.canUseMemberWeights ? 'membership' : 'value';
      this.setAllDialog = true;
    },
    resetWeights() {
      this.weightsSaving = true;
      const params = {poll_id: this.poll.id, mode: this.weightMode};
      if (this.weightMode === 'value') params.weight = this.resetWeight;
      Records.remote.patch('stances/reset_weights', params).then(() => Records.polls.remote.fetchById(this.poll.id)).then(() => {
        this.weightsByUserId = {};
        this.weightsSavedByUserId = {};
        this.fetchStances();
        this.setAllDialog = false;
        Flash.success('poll_common_form.vote_weights_updated');
      }).catch(error => Flash.fromServer(error)).finally(() => { this.weightsSaving = false; });
    },
    canPerform(action, poll, user) {
      switch (action) {
        case 'revoke':
          return poll.adminsInclude(Session.user());
      }
    },

    perform(action, poll, user) {
      this.service[action].perform(poll, user).then(() => {
        delete this.stanceIdsByUserId[user.id];
        delete this.weightsByUserId[user.id];
        delete this.weightsSavedByUserId[user.id];
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
      this.page = 1;
      this.userIds = [];
      this.users = [];
      this.voterTotal = 0;
      this.loading = true;
      this.fetchStances();
    },

    changePage(page) {
      this.page = page;
      this.userIds = [];
      this.users = [];
      this.loading = true;
      this.fetchStances();
    },

    fetchStances: debounce(function() {
      this.loading = true;
      const query = this.query;
      const page = this.page;
      const sequence = ++this.fetchSequence;
      Records.fetch({
        path: 'stances/users',
        params: {
          exclude_types: 'poll group',
          poll_id: this.poll.id,
          query,
          from: (page - 1) * this.per,
          per: this.per
      }}).then(data => {
        if (sequence !== this.fetchSequence || query !== this.query || page !== this.page) return;
        this.voterTotal = data.meta.total;
        if (this.page > this.totalPages) {
          this.changePage(this.totalPages);
          return;
        }
        this.isGuest = this.toHash(data.meta.guest_ids);
        this.isGroupAdmin = this.toHash(data.meta.group_admin_ids);
        this.isTopicAdmin = this.toHash(data.meta.topic_admin_ids);
        if (this.canManageWeights) {
          Object.assign(this.stanceIdsByUserId, data.meta.stance_ids_by_user_id || {});
          Object.entries(data.meta.weights_by_user_id || {}).forEach(([id, weight]) => {
            if (!(id in this.weightsByUserId)) this.weightsByUserId[id] = String(weight);
            this.weightsSavedByUserId[id] = String(weight);
          });
        }
        this.userIds = map(data.users, 'id');
        this.updateStances();
      }).catch(error => {
        Flash.fromServer(error);
      }).finally(() => {
        if (sequence === this.fetchSequence && query === this.query && page === this.page) this.loading = false;
      });
    } , 300),

    updateStances() {
      this.users = Records.users.findByIds(this.userIds).sort((a, b) => a.id - b.id);
    }
  }
};
</script>

<template lang="pug">
v-card.poll-members-form(:title="t('poll_common_form.voters')")
  template(v-slot:append)
    dismiss-modal-button
  .px-4.pt-4
    h2.text-title-large(v-if="!poll.closedAt") {{ t('poll_common_form.add_voters') }}
    recipients-autocomplete(
      v-if="!poll.closedAt"
      :label="poll.notifyRecipients ? $t('announcement.form.'+wipOrEmpty+'poll_announced.helptext') : $t('poll_common_form.who_may_vote', {poll_type: poll.translatedPollType()})"
      :placeholder="$t('announcement.form.placeholder')"
      :model="poll"
      :reset="reset"
      :excludedAudiences="['voters', 'undecided_voters', 'non_voters', 'decided_voters']"
      :excludedUserIds="userIds"
      :initialRecipients="initialRecipients"
      includeActor
      :excludeMembers="true")

    .d-flex.align-center(v-if="!poll.closedAt && !isScheduled")
      v-checkbox(:disabled="!someRecipients" :label="$t('poll_common_form.notify_invitees')" v-model="poll.notifyRecipients")
      v-spacer
      v-btn.poll-members-form__submit(color="primary" :disabled="!someRecipients" :loading="saving" @click="inviteRecipients" )
        span(v-t="'common.action.invite'" v-if="poll.notifyRecipients")
        span(v-t="'poll_common_form.add_voters'" v-else)
    .d-flex.align-center(v-if="!poll.closedAt && isScheduled")
      v-spacer
      v-btn.poll-members-form__submit(color="primary" :disabled="!someRecipients" :loading="saving" @click="inviteRecipients" )
        span(v-t="'poll_common_form.add_voters'")
    v-alert(density="compact" type="info" text v-if="!poll.closedAt && isScheduled && someRecipients")
      span(v-t="'poll_common_form.voters_notified_when_opens'")
    v-alert(density="compact" type="warning" text v-if="!poll.closedAt && !isScheduled && someRecipients && !poll.notifyRecipients")
      span(v-t="'poll_common_form.no_notifications_warning'")
    v-textarea(v-if="!poll.closedAt && !isScheduled && poll.notifyRecipients && someRecipients" filled rows="3" v-model="message" :label="$t('announcement.form.invitation_message_label')" :placeholder="$t('announcement.form.invitation_message_placeholder')")
  .d-flex.align-center.ga-3.px-4.pt-4
    h2.text-title-medium.mb-0 {{ t('membership_card.voters') }}
    v-spacer
    v-text-field.poll-members-form__search(
      :model-value="query"
      @update:model-value="newQuery"
      :label="t('poll_common_form.search_voters')"
      clearable
      density="compact"
      hide-details)
  v-list.poll-members-form__list
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
          v-model="weightsByUserId[user.id]"
          type="text"
          inputmode="decimal"
          density="compact"
          hide-details
          :aria-label="$t('poll_common_form.vote_weight_for', {name: user.name})")
        v-menu(v-if="performableActions(poll, user).length" offset-y)
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
    .d-flex.justify-center(v-if="loading")
      loading
  .d-flex.flex-wrap.align-center.justify-space-between.ga-2.px-4.py-2
    span.poll-members-form__page-count.text-body-small.text-medium-emphasis {{ t('poll_common_form.voter_page_count', {first: pageFirst, last: pageLast, total: voterTotal}) }}
    v-pagination.poll-members-form__pagination(
      v-if="totalPages > 1"
      :model-value="page"
      :length="totalPages"
      :disabled="loading"
      @update:model-value="changePage")
  .d-flex.flex-wrap.align-center.ga-2.justify-end.mx-4.pb-4
    v-btn(v-if="canManageWeights" variant="tonal" :disabled="weightsSaving" @click="openSetAllDialog") {{ t('poll_common_form.set_all') }}
    v-btn(v-if="canManageWeights" color="primary" :disabled="!weightsDirty || !weightsValid" :loading="weightsSaving" @click="saveWeights")
      span {{ t('poll_common_form.save_vote_weights') }}
    help-btn(
      path="en/user_manual/polls/inviting_people#add-voters-to-the-poll")
    v-spacer
  v-dialog(v-model="setAllDialog" max-width="480")
    v-card(:title="t('poll_common_form.set_all_vote_weights')")
      v-card-text
        v-radio-group(v-model="weightMode" hide-details)
          v-radio(v-if="canUseMemberWeights" value="membership" :label="t('poll_common_form.use_member_vote_weights')")
          v-radio(value="value" :label="t('poll_common_form.set_one_vote_weight')")
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
        v-btn(variant="text" :disabled="weightsSaving" @click="setAllDialog = false") {{ t('common.action.cancel') }}
        v-btn(color="primary" :disabled="weightsSaving || (weightMode === 'value' && !voteWeightValid(resetWeight))" :loading="weightsSaving" @click="resetWeights") {{ t('poll_common_form.set_all') }}
</template>

<style>
.poll-members-form__weight {
  max-width: 112px;
}


.poll-members-form__search {
  max-width: 220px;
}

.poll-members-form {
  max-height: 90dvh;
  overflow-y: auto;
}

.poll-members-form__list {
  max-height: 40dvh;
  overflow-y: auto;
}
</style>
