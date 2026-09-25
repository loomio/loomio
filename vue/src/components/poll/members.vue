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
      query: '',
      searchOpen: false,
      message: '',
      stanceIdsByUserId: {},
      weightsByUserId: {},
      weightsSaving: false,
      weightUser: null,
      weightValue: '',
      weightDialog: false,
      removeUser: null,
      removeDialog: false,
      removing: false,
      resetWeight: '1',
      weightMode: 'membership',
      setAllDialog: false,
      voterTotal: 0,
      page: 1,
      per: 50,
      fetchSequence: 0
    };
  },

  mounted() {
    this.poll.notifyRecipients = !(this.poll.openingAt && !this.poll.openedAt);
    this.fetchStances();
    this.updateStances();

    this.watchRecords({
      collections: ['stances', 'memberships', 'users'],
      query: records => this.updateStances()
    });
  },

  computed: {
    isScheduled() { return this.poll.openingAt && !this.poll.openedAt; },
    someRecipients() {
      return this.poll.recipientAudience ||
      this.poll.recipientUserIds.length ||
      this.poll.recipientEmails.length ||
      this.poll.recipientChatbotIds.length;
    },
    canManageWeights() {
      return this.poll.voteWeightsEnabled && !this.poll.closedAt && this.poll.adminsInclude(Session.user());
    },
    canRemoveVoters() {
      return !this.poll.detachedAnonymousVoting() && this.poll.adminsInclude(Session.user());
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
    openWeightDialog(user) {
      this.weightUser = user;
      this.weightValue = this.weightsByUserId[user.id];
      this.weightDialog = true;
    },
    saveWeight() {
      if (this.weightsSaving || !voteWeightValid(this.weightValue)) return;
      const user = this.weightUser;
      this.weightsSaving = true;
      Records.remote.patch(`stances/${this.stanceIdsByUserId[user.id]}/set_weight`, {weight: this.weightValue}).then(() => Records.polls.remote.fetchById(this.poll.id)).then(() => {
        this.weightsByUserId[user.id] = this.weightValue;
        this.weightDialog = false;
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
        this.fetchStances();
        this.setAllDialog = false;
        Flash.success('poll_common_form.vote_weights_updated');
      }).catch(error => Flash.fromServer(error)).finally(() => { this.weightsSaving = false; });
    },
    openRemoveDialog(user) {
      this.removeUser = user;
      this.removeDialog = true;
    },

    removeVoter() {
      const user = this.removeUser;
      this.removing = true;
      StanceService.revoke.perform(this.poll, user).then(() => {
        delete this.stanceIdsByUserId[user.id];
        delete this.weightsByUserId[user.id];
        this.fetchStances();
        this.removeDialog = false;
      }).catch(error => {
        Flash.fromServer(error);
      }).finally(() => {
        this.removing = false;
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
      if (this.query === query) return;
      this.query = query;
      this.page = 1;
      this.userIds = [];
      this.users = [];
      this.voterTotal = 0;
      this.loading = true;
      this.fetchStances();
    },

    openSearch() {
      this.searchOpen = true;
      this.$nextTick(() => document.getElementById('poll-voter-search').focus());
    },

    closeSearch() {
      this.searchOpen = false;
      this.newQuery('');
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
      this.users = this.userIds.map(id => Records.users.findById(id));
    }
  }
};
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
      :placeholder="$t('announcement.form.placeholder')"
      :model="poll"
      :reset="reset"
      :excludedAudiences="['voters', 'undecided_voters', 'non_voters', 'decided_voters']"
      :excludedUserIds="userIds"
      :initialRecipients="initialRecipients"
      hideEmptyResults
      preserveSearchOnBlur
      @update:search="newQuery"
      includeActor
      :excludeMembers="true")
    v-alert(density="compact" type="info" text v-if="!poll.closedAt && isScheduled && someRecipients")
      span(v-t="'poll_common_form.voters_notified_when_opens'")
    .mt-3(v-if="!poll.closedAt && !isScheduled && someRecipients")
      v-textarea(v-if="poll.notifyRecipients" filled rows="3" hide-details v-model="message" :label="$t('announcement.form.invitation_message_label')" :placeholder="$t('announcement.form.invitation_message_placeholder')")
      v-alert(v-else density="compact" type="info" variant="outlined" color="grey" text)
        span {{ t('poll_common_form.voters_will_not_be_notified') }}
    .d-flex.align-center.mt-4(v-if="!poll.closedAt && someRecipients")
      v-checkbox(v-if="!isScheduled" :label="$t('poll_common_form.notify_invitees')" v-model="poll.notifyRecipients" hide-details)
      v-spacer
      v-btn.poll-members-form__submit(color="primary" :loading="saving" @click="inviteRecipients")
        span(v-if="isScheduled || !poll.notifyRecipients") {{ t('poll_common_form.add_voters') }}
        span(v-else) {{ t('common.action.invite') }}
  .d-flex.flex-wrap.align-center.ga-3.px-4.pt-4(v-if="!someRecipients && (poll.closedAt || canManageWeights)")
    v-btn.poll-members-form__search-toggle(v-if="poll.closedAt && !searchOpen" variant="text" icon :aria-label="t('poll_common_form.search_voters')" aria-controls="poll-voter-search" @click="openSearch")
      common-icon(name="mdi-magnify")
    v-text-field.poll-members-form__search(
      v-if="poll.closedAt && searchOpen"
      id="poll-voter-search"
      :model-value="query"
      @update:model-value="newQuery"
      :label="t('poll_common_form.search_voters')"
      prepend-inner-icon="mdi-magnify"
      density="compact"
      hide-details)
      template(v-slot:append-inner)
        v-btn.poll-members-form__search-close(variant="text" icon size="x-small" :aria-label="t('poll_common_form.close_search')" @click.stop="closeSearch")
          common-icon(name="mdi-close")
    v-spacer
    v-btn.poll-members-form__set-all(v-if="canManageWeights" variant="tonal" :disabled="weightsSaving" @click="openSetAllDialog") {{ t('poll_common_form.set_all_vote_weights') }}
  v-list.poll-members-form__list(v-if="!someRecipients" style="flex: 1; min-height: 0; overflow-y: auto")
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

    v-list-item(v-if="query && users.length == 0")
      v-list-item-title(v-t="{ path: 'discussions_panel.no_results_found', args: { search: query }}")
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
          v-radio(value="value" :label="t('poll_common_form.set_all_weights_the_same')")
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


.poll-members-form__search {
  max-width: 220px;
}

</style>
