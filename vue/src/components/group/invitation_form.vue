<script lang="js">
import Records        from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import AppConfig      from '@/shared/services/app_config';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import AbilityService from '@/shared/services/ability_service';
import Flash   from '@/shared/services/flash';
import { debounce } from 'lodash-es';
import { I18n } from '@/i18n';
import { mdiAccountMultiplePlus } from '@mdi/js';
import WatchRecords from '@/mixins/watch_records';

export default
{
  mixins: [WatchRecords],
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
      upgradeUrl: AppConfig.baseUrl + 'upgrade',
      invitationsRemaining: ((this.subscription && this.subscription.max_members) || 0) - this.group.parentOrSelf().orgMembersCount
    };
  },

  mounted() {
    this.message = AppConfig.theme.default_invitation_message || I18n.global.t('announcement.form.invitation_message_default');
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
        Records.groups.findOrFetchById(this.group.id);
        Flash.success('announcement.flash.success', { count: data.memberships.length });
        EventBus.$emit('closeModal');
      }).finally(() => {
        this.saving = false;
      });
    },

    updateInvitationsRemaining() {
      if (!this.subscription || !this.subscription.max_members) { return };
      Records.remote.get('announcements/new_member_count', {
        group_id: this.group.id,
        recipient_emails_cmr: this.recipients.filter(r => r.type === 'email').map(r => r.id).join(','),
        recipient_user_xids: this.recipients.filter(r => r.type === 'user').map(r => r.id).join('x')
      }).then(data => {
        this.invitationsRemaining = ((this.subscription && this.subscription.max_members) || 0) - this.group.parentOrSelf().orgMembersCount - data.count
      })
    },

    newQuery(query) {
      this.query = query;
      this.fetchMemberships();
      this.updateSuggestions();
    },

    newRecipients(recipients) {
      this.recipients = recipients;
      this.updateInvitationsRemaining();
    },

    updateSuggestions() {
      this.excludedUserIds = this.group.memberIds();
    },

    openShareableLinkForm() {
      EventBus.$emit('openModal', {
        component: 'GroupShareableLinkForm',
        props: {
          group: this.group
        }
      });
    },
  },

  computed: {
    invitableGroups() {
      return this.group.parentOrSelf().selfAndSubgroups().filter(g => AbilityService.canAddMembersToGroup(g));
    },
    tooManyInvitations() {
      return this.subscription.max_members && (this.invitationsRemaining < 0);
    },
  }
};


</script>
<template lang="pug">
v-card.group-invitation-form(:title="$t('announcement.send_group',  {name: group.name})")
  template(v-slot:append)
    dismiss-modal-button
  div.py-8(v-if="!subscription.active")
    .announcement-form__invite
      //- p(v-if="invitationsRemaining < 1" v-html="$t('announcement.form.no_invitations_remaining', {upgradeUrl: upgradeUrl, maxMembers: subscription.max_members})")
      p(v-html="$t('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")
  v-card-text(v-else)
    v-alert.mb-4(variant="tonal" color="info")
      p.mb-2(v-t="'invitation_form.enter_emails_of_people_to_invite'")
      p
        span(v-t="'invitation_form.already_chatting_somewhere'")
        space
        a.text-decoration-underline(style="color:inherit" @click="openShareableLinkForm" v-t="'invitation_form.try_the_shareable_link_instead'")

    recipients-autocomplete(
      :label="$t('announcement.form.who_to_invite')"
      :placeholder="$t('announcement.form.type_or_paste_email_addresses_to_invite')"
      :excluded-user-ids="excludedUserIds"
      :reset="reset"
      :model="group"
      :hide-count="tooManyInvitations"
      @new-query="newQuery"
      @new-recipients="newRecipients")
    div.text-medium-emphasis(v-if="subscription.max_members")
      p.text-caption(v-if="!tooManyInvitations" v-html="$t('announcement.form.invitations_remaining', {count: invitationsRemaining, upgradeUrl: upgradeUrl })")
      p.text-caption(v-if="tooManyInvitations" v-html="$t('announcement.form.too_many_invitations', {upgradeUrl: upgradeUrl})")
    div.mb-4(v-if="invitableGroups.length > 1")
      label.text-medium-emphasis.text-body-2(v-t="'announcement.select_groups'")
      div(v-for="group in invitableGroups", :key="group.id")
        v-checkbox.invitation-form__select-groups(
          density="compact"
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
    help-btn(path="en/user_manual/groups/membership")
    v-spacer
    v-btn.announcement-form__submit(
      variant="elevated"
      color="primary"
      :disabled="!recipients.length || tooManyInvitations || groupIds.length == 0"
      @click="inviteRecipients"
      :loading="saving"
    )
      span(v-t="'common.action.invite'")

</template>
<style lang="css">

.invitation-form__select-groups {
  margin-top: 8px;
}

</style>
