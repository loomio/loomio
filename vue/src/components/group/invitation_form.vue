<script lang="js">
import GroupService from '@/shared/services/group_service';
import Records        from '@/shared/services/records';
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import AppConfig      from '@/shared/services/app_config';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import AbilityService from '@/shared/services/ability_service';
import Flash   from '@/shared/services/flash';
import { uniq, debounce } from 'lodash-es';
import I18n from '@/i18n';
import { mdiAccountMultiplePlus } from '@mdi/js';

export default
{
  components: {
    RecipientsAutocomplete
  },

  props: {
    group: Object
  },

  data() {
    return {
      mdiAccountMultiplePlus,
      query: '',
      recipients: [],
      reset: false,
      saving: false,
      groupIds: [this.group.id],
      excludedUserIds: [],
      message: null,
      subscription: this.group.parentOrSelf().subscription,
      cannotInvite: false,
      upgradeUrl: AppConfig.baseUrl + 'upgrade'
    };
  },

  mounted() {
    this.message = I18n.t('announcement.form.invitation_message_default');

    this.updateSuggestions();
    this.watchRecords({
      collections: ['memberships', 'groups'],
      query: records => { 
        this.updateSuggestions();
        this.subscription = this.group.parentOrSelf().subscription;
        return this.cannotInvite = !this.subscription.active || (this.subscription.max_members && (this.invitationsRemaining < 1));
      }
    });
  },

  methods: {
    fetchMemberships: debounce(function() {
      this.loading = true;
      Records.memberships.fetch({
        params: {
          exclude_types: 'group',
          q: this.query,
          group_id: this.group.id,
          per: 20
        }}).finally(() => {
        return this.loading = false;
      });
    }
    , 300),

    inviteRecipients() {
      this.saving = true;
      Records.remote.post('announcements', {
        group_id: this.group.id,
        invited_group_ids: this.groupIds,
        recipient_emails: this.recipients.filter(r => r.type === 'email').map(r => r.id),
        recipient_user_ids: this.recipients.filter(r => r.type === 'user').map(r => r.id),
        recipient_message: this.message
      }).then(data => {
        Flash.success('announcement.flash.success', { count: data.memberships.length });
        EventBus.$emit('closeModal');
      }).finally(() => {
        this.saving = false;
      });
    },

    newQuery(query) {
      this.query = query;
      this.fetchMemberships();
      this.updateSuggestions();
    },

    newRecipients(recipients) { return this.recipients = recipients; },

    updateSuggestions() {
      this.excludedUserIds = this.group.memberIds();
    }
  },

    // findUsers: ->
    //   userIdsInGroup = Records.memberships.collection.
    //     chain().find(groupId: @group.id).
    //     data().map (m) -> m.userId
    //   membershipsChain = Records.memberships.collection.chain()
    //   membershipsChain = membershipsChain.find(groupId: { $in: @group.parentOrSelf().organisationIds() })
    //   membershipsChain = membershipsChain.find(userId: { $nin: userIdsInGroup })
    //
    //   userIdsNotInGroup = uniq membershipsChain.data().map((m) -> m.userId)
    //
    //   chain = Records.users.collection.chain()
    //   chain = chain.find(id: {$in: userIdsNotInGroup})
    //
    //
    //   if @query
    //     chain = chain.find
    //       $or: [
    //         {name: {'$regex': ["^#{@query}", "i"]}}
    //         {username: {'$regex': ["^#{@query}", "i"]}}
    //         {name: {'$regex': [" #{@query}", "i"]}}
    //       ]
    //   chain.data()

  computed: {
    invitableGroups() {
      return this.group.parentOrSelf().selfAndSubgroups().filter(g => AbilityService.canAddMembersToGroup(g));
    },
    tooManyInvitations() {
      return this.subscription.max_members && (this.invitationsRemaining < 0);
    },
    invitationsRemaining() {
      return (this.subscription.max_members || 0) - this.group.parentOrSelf().orgMembershipsCount - this.recipients.length;
    }
  }
};


</script>
<template lang="pug">
.group-invitation-form
  .px-4.pt-4
    .d-flex.justify-space-between
      h1.text-h5(tabindex="-1" v-t="{path: 'announcement.send_group', args: {name: group.name} }")
      dismiss-modal-button

    div.py-4(v-if="cannotInvite")
      .announcement-form__invite
        p(v-if="invitationsRemaining < 1" v-html="$t('announcement.form.no_invitations_remaining', {upgradeUrl: upgradeUrl, maxMembers: subscription.max_members})")
        p(v-if="!subscription.active" v-html="$t('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")
    div(v-else)
      v-alert.my-2(v-if="group.membershipsCount < 2" type="info" outlined text :icon="mdiAccountMultiplePlus") 
        span(v-t="'announcement.form.invite_people_to_evaluate_loomio'") 
      recipients-autocomplete(
        :label="$t('announcement.form.who_to_invite')"
        :placeholder="$t('announcement.form.type_or_paste_email_addresses_to_invite')"
        :excluded-user-ids="excludedUserIds"
        :reset="reset"
        :model="group"
        @new-query="newQuery"
        @new-recipients="newRecipients")
      div(v-if="subscription.max_members")
        p.text-caption(v-if="!tooManyInvitations" v-html="$t('announcement.form.invitations_remaining', {count: invitationsRemaining, upgradeUrl: upgradeUrl })")
        p.text-caption(v-if="tooManyInvitations" v-html="$t('announcement.form.too_many_invitations', {upgradeUrl: upgradeUrl})")
      div.mb-4(v-if="invitableGroups.length > 1")
        label.lmo-label(v-t="'announcement.select_groups'")
        //- v-label Select groups
        div(v-for="group in invitableGroups", :key="group.id")
          v-checkbox.invitation-form__select-groups(
            :class="{'ml-4': !group.isParent()}"
            v-model="groupIds"
            :label="group.name"
            :value="group.id" 
            hide-details)

      v-textarea(
        filled
        rows="3"
        v-model="message"
        :label="$t('announcement.form.invitation_message_label')"
        :placeholder="$t('announcement.form.invitation_message_placeholder')")

      v-card-actions
        help-link(path="en/user_manual/groups/membership")
        v-spacer
        v-btn.announcement-form__submit(
          color="primary"
          :disabled="!recipients.length || tooManyInvitations || groupIds.length == 0"
          @click="inviteRecipients"
          :loading="saving"
        )
          span(v-t="'common.action.invite'")

</template>
<style lang="css">

.lmo-label {
  color: rgba(0, 0, 0, 0.6);
  height: 20px;
  line-height: 20px;
  max-width: 133%;
  transform: translateY(-18px) scale(0.75);
  max-width: 90%;
  overflow: hidden;
  text-overflow: ellipsis;
  top: 6px;
  white-space: nowrap;
  pointer-events: none;
  font-size: 12px;
  line-height: 1;
  min-height: 8px;
  transition: 0.3s cubic-bezier(0.25, 0.8, 0.5, 1);
}

.invitation-form__select-groups {
  margin-top: 8px;
}

</style>
