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

<template>

<v-dialog v-model="dialog" max-width="600px">
  <template v-slot:activator="{ on, attrs }">
    <v-btn class="mr-2" v-on="on" v-bind="attrs" color="primary" outlined="outlined" v-t="'members_panel.sharable_link'"></v-btn>
  </template>
  <v-card class="shareable-link-modal">
    <v-card-title>
      <h1 class="headline" tabindex="-1" v-t="'invitation_form.share_group'"></h1>
      <v-spacer></v-spacer>
      <v-btn class="dismiss-modal-button" icon="icon" small="small" @click="dialog = false">
        <common-icon name="mdi-window-close"></common-icon>
      </v-btn>
    </v-card-title>
    <v-card-text>
      <template v-if="group.groupPrivacy != 'secret'"><span class="subtitle-2" v-t="'invitation_form.group_url'"></span>
        <p class="mt-2 mb-0 caption" v-t="'invitation_form.secret_group_url_explanation'"></p>
        <v-layout align-center="align-center">
          <v-text-field class="shareable-link-modal__shareable-link" :value="groupUrl" :disabled="true"></v-text-field>
          <v-btn class="shareable-link-modal__copy" icon="icon" color="primary" :title="$t('common.copy')" @click="copyText(groupUrl)">
            <common-icon name="mdi-content-copy"></common-icon>
          </v-btn>
        </v-layout>
      </template>
      <div v-if="canAddMembers"><span class="subtitle-2" v-t="'invitation_form.reusable_invitation_link'"></span>
        <p class="mt-2 mb-0 caption" v-t="'invitation_form.shareable_invitation_explanation'"></p>
        <v-layout align-center="align-center">
          <v-text-field class="shareable-link-modal__shareable-link" :value="invitationLink" :disabled="true"></v-text-field>
          <v-btn class="shareable-link-modal__copy" icon="icon" color="primary" :title="$t('common.copy')" @click="copyText(invitationLink)">
            <common-icon name="mdi-content-copy"></common-icon>
          </v-btn>
          <v-btn class="shareable-link-modal__reset" icon="icon" color="warning" :title="$t('common.reset')" @click="resetInvitationLink()">
            <common-icon name="mdi-lock-reset"></common-icon>
          </v-btn>
        </v-layout>
      </div>
      <v-btn href="https://help.loomio.org/en/user_manual/groups/membership/" target="_blank" v-t="'common.help'"></v-btn>
    </v-card-text>
  </v-card>
</v-dialog>
</template>
