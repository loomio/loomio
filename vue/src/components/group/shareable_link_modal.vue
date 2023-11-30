<script lang="js">
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import utils          from '@/shared/record_store/utils';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import AbilityService from '@/shared/services/ability_service';

import Flash   from '@/shared/services/flash';


export default
{
  props: {
    group: Object
  },
  data() {
    return {dialog: false};
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
v-dialog(v-model='dialog' max-width="600px")
  template(v-slot:activator="{ on, attrs }")
    v-btn.mr-2(v-on="on" v-bind="attrs" color="primary" outlined v-t="'members_panel.sharable_link'")
  v-card.shareable-link-modal
    v-card-title
      h1.text-h5(tabindex="-1" v-t="'invitation_form.share_group'")
      v-spacer
      v-btn.dismiss-modal-button(icon small @click='dialog = false')
        common-icon(name="mdi-window-close")
    v-card-text
      template(v-if="group.groupPrivacy != 'secret'")
        span.subtitle-2(v-t="'invitation_form.group_url'")
        p.mt-2.mb-0.caption(v-t="'invitation_form.secret_group_url_explanation'")
        v-layout(align-center)
          v-text-field.shareable-link-modal__shareable-link(:value='groupUrl' :disabled='true')
          v-btn.shareable-link-modal__copy(icon color="primary" :title="$t('common.copy')" @click='copyText(groupUrl)')
            common-icon(name="mdi-content-copy")
      div(v-if="canAddMembers")
        span.subtitle-2(v-t="'invitation_form.reusable_invitation_link'")
        p.mt-2.mb-0.caption(v-t="'invitation_form.shareable_invitation_explanation'")
        v-layout(align-center)
          v-text-field.shareable-link-modal__shareable-link(:value='invitationLink' :disabled='true')
          v-btn.shareable-link-modal__copy(icon color="primary" :title="$t('common.copy')" @click='copyText(invitationLink)')
            common-icon(name="mdi-content-copy")
          v-btn.shareable-link-modal__reset(icon color="warning" :title="$t('common.reset')" @click="resetInvitationLink()")
            common-icon(name="mdi-lock-reset")

      v-btn(href="https://help.loomio.org/en/user_manual/groups/membership/" target="_blank" v-t="'common.help'")
</template>
