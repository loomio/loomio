<script lang="js">
import LmoUrlService  from '@/shared/services/lmo_url_service';
import AbilityService from '@/shared/services/ability_service';
import Flash   from '@/shared/services/flash';

export default
{
  props: {
    group: Object
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
      this.group.resetToken().then(() => {
        Flash.success('invitation_form.shareable_link_reset');
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

    canAddMembers() {
      return AbilityService.canAddMembersToGroup(this.group) && !this.pending;
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
    dismiss-modal-button
  v-card-text
    v-alert.mb-2(color="info" variant="tonal")
      span(v-t="'invitation_form.shareable_invitation_explanation'")
      space
      help-link(path="user_manual/groups/membership/#share-a-link-to-your-group")
    v-text-field.shareable-link-modal__shareable-link(:value='invitationLink' readonly variant="outlined" color="info")
      template(v-slot:append-inner)
        v-tooltip(location="bottom")
          template(v-slot:activator="{ props }")
            v-btn.shareable-link-modal__copy(v-bind="props" icon variant="tonal" color="info" :title="$t('common.copy')" @click='copyText(invitationLink)' )
              common-icon(name="mdi-content-copy")
          span(v-t="'invitation_form.copy_to_clipboard'")

    p(v-t="'invitation_form.to_stop_people_reset_the_link'")
  v-card-actions
    v-btn.shareable-link-modal__reset(:title="$t('common.reset')" @click="resetInvitationLink()" color="error")
      common-icon.mr-2(name="mdi-lock-reset")
      span(v-t="'invitation_form.reset_the_link'")
    v-spacer

</template>
