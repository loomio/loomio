<script lang="js">
import Session from '@/shared/services/session';
import AppConfig from '@/shared/services/app_config';
import GroupService from '@/shared/services/group_service';
import Flash from '@/shared/services/flash';
import Records from '@/shared/services/records';

export default 
{
  props: {
    group: Object
  },

  data() {
    return {
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
      return `${this.group.fullName} <${this.group.handle}+u=${Session.user().id}&k=${this.key}@${AppConfig.theme['reply_hostname']}>`;
    }
  },

  methods: {
    resetKey() {
      this.loading = true;
      Records.remote.post('profile/reset_email_api_key').then(data => {
        this.key = data.email_api_key;
        Flash.success('email_to_group.new_address_generated');
    }).finally(() => {
        this.loading = false;
        this.confirmReset = false;
      });
    },

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
<template>

<v-card class="email-to-group-settings">
  <div v-if="!confirmReset">
    <v-card-title>
      <h1 class="text-h6" v-t="'email_to_group.start_threads_via_email'"></h1>
      <v-spacer></v-spacer>
      <dismiss-modal-button></dismiss-modal-button>
    </v-card-title>
    <v-card-text>
      <p v-t="'email_to_group.your_address_for_this_group'"></p>
      <v-text-field readonly="readonly" outlined="outlined" v-model="address" append-icon="mdi-content-copy" @click:append="copyText"></v-text-field>
      <p><span v-t="'email_to_group.send_email_to_start_thread'"></span>
        <space></space><span v-t="'email_to_group.subject_body_attachments'"></span>
        <space></space><span v-t="'email_to_group.address_starts_threads_as_you'"></span>
      </p>
      <div class="d-flex flex-wrap">
        <v-btn @click="confirmReset = true" v-t="'common.reset'"></v-btn>
        <v-spacer></v-spacer>
      </div>
    </v-card-text>
  </div>
  <div v-if="confirmReset">
    <v-card-title>
      <h1 class="text-h6" v-t="'email_to_group.generate_new_address_question'"></h1>
    </v-card-title>
    <v-card-text>
      <p v-t="'email_to_group.generate_new_address_warning'"></p>
      <div class="d-flex">
        <v-btn @click="confirmReset = false" v-t="'common.action.cancel'"></v-btn>
        <v-spacer></v-spacer>
        <v-btn :loading="loading" @click="resetKey" v-t="'email_to_group.generate_new_address'"></v-btn>
      </div>
    </v-card-text>
  </div>
</v-card>
</template>
