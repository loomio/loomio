<script lang="js">
import LmoUrlService  from '@/shared/services/lmo_url_service';
import AppConfig from '@/shared/services/app_config';
import GroupAbility from '@/shared/abilities/group_ability';
import Session from '@/shared/services/session';
import SubscriptionService from '@/shared/services/subscription_service';
import Flash   from '@/shared/services/flash';

export default
{
  props: {
    group: Object
  },

  data() {
    return {
      confirmReset: false,
      resetting: false
    };
  },

  mounted() {
    this.group.fetchToken()
  },
  methods: {
    copyText(text) {
      navigator.clipboard.writeText(text).then(() => Flash.success('common.copied')
      , () => Flash.error('invitation_form.error'));
    },

    resetInvitationLink() {
      this.resetting = true;
      this.group.resetToken().then(() => {
        this.confirmReset = false;
        Flash.success('invitation_form.shareable_link_reset');
      }).finally(() => {
        this.resetting = false;
      });
    }
  },

  computed: {
    groupUrl() {
      return LmoUrlService.group(this.group, null, { absolute: true });
    },

    invitationLink() {
      if (this.group.token) {
        return LmoUrlService.shareableLink(this.group);
      } else {
        return this.$t('common.action.loading');
      }
    },

    invitationMessage() {
      return this.$t('invitation_form.shareable_invitation_message', {
        groupName: this.group.name,
        site_name: AppConfig.theme?.site_name || 'Loomio',
        link: this.invitationLink
      });
    },

    canAddMembers() {
      return GroupAbility.canAddMembers(this.group) && !this.pending;
    },

    showTrialNote() {
      return !Session.user().emailInvitationsAllowed() && !this.group.emailInvitationsAllowed();
    },

    upgradeUrl() {
      return SubscriptionService.upgradeUrl(this.group.parentOrSelf());
    },

    maxMembers() {
      return this.group.parentOrSelf().subscription?.max_members;
    },

    membersUsed() {
      return this.group.parentOrSelf().orgMembersCount || 0;
    }
  },

  watch: {
    dialog(val) {
      if (!!val) { this.group.fetchToken(); }
    }
  }
};
</script>

<template lang="pug">
v-card.shareable-link-modal(:title="$t('invitation_form.shareable_link_to_join_group')")
  template(v-slot:append)
    help-btn.text-medium-emphasis.mr-2(path="en/user_manual/groups/inviting_people#share-a-link-to-your-group" variant="text")
    dismiss-modal-button
  v-card-text
    v-alert.mb-4(color="info" variant="tonal")
      span(v-if="showTrialNote" v-html="$t('invitation_form.trial_shareable_link_note', { upgradeUrl })")
      span(v-else) {{ $t('invitation_form.shareable_invitation_explanation') }}
    v-text-field.shareable-link-modal__shareable-link(
      :model-value="invitationLink"
      :label="$t('invitation_form.invite_link')"
      readonly
      variant="outlined"
      color="info"
    )
      template(v-slot:append-inner)
        v-btn.shareable-link-modal__copy(variant="tonal" color="primary" size="small" @click='copyText(invitationLink)')
          common-icon.mr-1(name="mdi-content-copy" size="small")
          span {{ $t('common.copy') }}

    v-textarea.shareable-link-modal__message(
      :model-value="invitationMessage"
      :label="$t('invitation_form.shareable_invitation_message_label')"
      readonly
      auto-grow
      hide-details
      rows="3"
      variant="outlined"
      color="info"
    )
      template(v-slot:append-inner)
        v-btn.shareable-link-modal__copy-message(variant="tonal" color="primary" size="small" @click="copyText(invitationMessage)")
          common-icon.mr-1(name="mdi-content-copy" size="small")
          span {{ $t('common.copy') }}

  v-card-actions
    v-btn.shareable-link-modal__reset(:title="$t('common.reset')" @click="confirmReset = true" color="error")
      common-icon.mr-2(name="mdi-lock-reset")
      span {{ $t('invitation_form.reset_the_link') }}
    v-spacer
    span.shareable-link-modal__members.text-body-small.text-medium-emphasis.mr-2(v-if="maxMembers")
      | {{ $t('invitation_form.members_used', { used: membersUsed, max: maxMembers }) }}

  v-dialog(v-model="confirmReset" max-width="480")
    v-card.shareable-link-modal__reset-confirm(:title="$t('invitation_form.reset_the_link')")
      v-card-text
        p {{ $t('invitation_form.to_stop_people_reset_the_link') }}
      v-card-actions
        v-spacer
        v-btn.shareable-link-modal__reset-cancel(variant="text" @click="confirmReset = false") {{ $t('common.action.cancel') }}
        v-btn.shareable-link-modal__reset-submit(color="error" variant="elevated" :loading="resetting" @click="resetInvitationLink()") {{ $t('invitation_form.reset_the_link') }}

</template>
