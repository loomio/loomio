<script lang="js">
import Session from '@/shared/services/session';
import AppConfig from '@/shared/services/app_config';
import GroupService from '@/shared/services/group_service';
import Flash from '@/shared/services/flash';
import Records from '@/shared/services/records';
import { mdiContentCopy } from '@mdi/js';

export default 
{
  props: {
    group: Object
  },

  data() {
    return {
      mdiContentCopy,
      key: null,
      confirmReset: false,
      loading: false
    };
  },

  created() {
    Records.remote.get('profile/email_api_key').then(data => {
      this.key = data.email_api_key;
    });
  },

  computed: {
    address() {
      return `${this.group.fullName} <${this.group.handle}@${AppConfig.theme['reply_hostname']}>`;
    }
  },

  methods: {
    copyText() {
      navigator.clipboard.writeText(this.address);
      Flash.success("email_to_group.email_address_copied_to_clipboard");
    },

    sendGroupAddress() {
      Records.remote.post('profile/send_email_to_group_address', {group_id: this.group.id}).then(() => {
        Flash.success('email_to_group.email_address_sent_to_you');
      });
    }
  }
};

</script>
<template lang="pug">
v-card.email-to-group-settings
  div
    v-card-title
      h1.text-h6(v-t="'email_to_group.start_a_thread_by_email'")
      v-spacer
      dismiss-modal-button

    .pa-4
      v-text-field(
        readonly
        outlined
        filled
        v-model="address"
        :append-icon="mdiContentCopy"
        @click:append="copyText"
      )
      .text--secondary
        p
          span(v-t="'email_to_group.send_email_to_start_thread'")
          space
          span(v-t="'email_to_group.subject_body_attachments'")
        p
          span(v-t="'email_to_group.forward_email_to_move_conversation'")

</template>
