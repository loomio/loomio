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
      // return `${this.group.fullName} <${this.group.handle}@${AppConfig.theme['reply_hostname']}>`;
      return `${this.group.handle}@${AppConfig.theme['reply_hostname']}`;
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
v-card.email-to-group-settings(:title="$t('email_to_group.start_a_discussion_by_email')")
  template(v-slot:append)
      dismiss-modal-button
  v-card-text
    p.text-medium-emphasis.pb-2(v-t="'email_to_group.send_email_to_start_discussion'")
    v-text-field(
      readonly
      variant="solo-filled"
      v-model="address"
      :append-icon="mdiContentCopy"
      @click:append="copyText"
    )
    p.text-medium-emphasis.pb-2(v-t="'email_to_group.subject_body_attachments'")
    p.text-medium-emphasis.pb-2(v-t="'email_to_group.forward_email_to_move_conversation'")

</template>
