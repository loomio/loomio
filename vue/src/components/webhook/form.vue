<script lang="js">
import EventBus from '@/shared/services/event_bus';
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';
import Flash  from '@/shared/services/flash';

export default {
  props: {
    close: Function,
    webhook: Object
  },

  data() {
    return {
      tab: 'webhook',
      kinds: AppConfig.webhookEventKinds,
      permissions: ['show_discussion', 'create_discussion', 'show_poll', 'create_poll', 'read_memberships', 'manage_memberships']
    };
  },

  methods: {
    docsUrl(key) {
      return AppConfig.baseUrl + `help/api?api_key=${key}`;
    },

    submit() {
      this.webhook.save().then(() => {
        Flash.success('webhook.success');
        this.close();
      }).catch(b => {
        console.log(this.webhook.errors);
      });
    }
  }
};
</script>
<template>

<v-card class="webhook-form">
  <form @submit.prevent="submit">
    <v-card-title>
      <h1 class="headline" tabindex="-1" v-t="!webhook.id ? 'webhook.add_api_key' : 'webhook.edit_api_key'"></h1>
      <v-spacer></v-spacer>
      <dismiss-modal-button :close="close"></dismiss-modal-button>
    </v-card-title>
    <v-card-text class="install-webhook-form">
      <v-text-field class="webhook-form__name" v-model="webhook.name" required="required" :label="$t('webhook.name_label')" :placeholder="$t('webhook.name_placeholder')"></v-text-field>
      <validation-errors :subject="webhook" field="name"></validation-errors><a v-if="webhook.id" :href="docsUrl(webhook.token)" v-t="'webhook.show_docs'" target="_blank"></a>
      <p v-if="!webhook.id" v-t="'webhook.save_to_show_docs'"></p>
      <p class="pt-4 text--secondary" v-t="'webhook.permissions_explaination'"></p>
      <v-checkbox class="webhook-form__permission" hide-details="hide-details" v-for="permission in permissions" v-model="webhook.permissions" :key="permission" :label="$t('webhook.permissions.' + permission)" :value="permission"></v-checkbox>
    </v-card-text>
    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn color="primary" type="submit" v-t="'common.action.save'" :loading="webhook.processing"></v-btn>
    </v-card-actions>
  </form>
</v-card>
</template>
