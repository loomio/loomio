<script lang="js">
import EventBus from '@/shared/services/event_bus';
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';
import Flash  from '@/shared/services/flash';

export default {
  props: {
    chatbot: Object
  },

  data() {
    return {
      kinds: AppConfig.webhookEventKinds,
      testing: false,
      formats: [
        {text: this.$t('webhook.formats.markdown'), value: "markdown"},
        {text: this.$t('webhook.formats.microsoft'), value: "microsoft"},
        {text: this.$t('webhook.formats.slack'), value: "slack"},
        {text: this.$t('webhook.formats.discord'), value: "discord"}
        ]
    };
  },

  methods: {
    destroy() {
      this.chatbot.destroy().then(() => {
        Flash.success('poll_common_delete_modal.success');
        EventBus.$emit('closeModal');
      }).catch(b => {
        Flash.error('common.something_went_wrong');
        console.log(this.chatbot.errors);
      });
    },

    submit() {
      this.chatbot.save().then(() => {
        Flash.success('chatbot.saved');
        EventBus.$emit('closeModal');
      }).catch(b => {
        Flash.warning('common.check_for_errors_and_try_again');
      });
    },

    testConnection() {
      this.testing = true;
      Records.remote.post('chatbots/test', {
        server: this.chatbot.server,
        kind: 'slack_webhook'
      }).finally(() => {
        Flash.success('chatbot.check_for_test_message');
        this.testing = false;
      });
    }
  },

  computed: {
    url() {
      switch (this.chatbot.webhookKind) {
      case "slack": return "https://help.loomio.com/en/user_manual/groups/integrations/slack";
      case "discord": return "https://help.loomio.com/en/user_manual/groups/integrations/discord";
      case "microsoft": return "https://help.loomio.com/en/user_manual/groups/integrations/microsoft_teams";
      case "mattermost": return "https://help.loomio.com/en/user_manual/groups/integrations/mattermost";
      }
    }
  }
};

</script>
<template>

<v-card class="chatbot-matrix-form">
  <v-card-title>
    <h1 class="headline" tabindex="-1"><span>Webhook</span>
      <space></space><span v-t="'chatbot.chatbot'"></span>
    </h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button></dismiss-modal-button>
  </v-card-title>
  <v-card-text>
    <v-text-field :label="$t('chatbot.name')" v-model="chatbot.name" hint="The name of your chatroom"></v-text-field>
    <validation-errors :subject="chatbot" field="name"></validation-errors>
    <v-text-field :label="$t('chatbot.webhook_url')" v-model="chatbot.server" hint="Looks like: https://hooks.example.com/services/abc/xyz/123"></v-text-field>
    <validation-errors :subject="chatbot" field="server"></validation-errors>
    <p class="mt-2 mb-2" v-html="$t('webhook.we_have_guides', {url: url})"></p>
    <v-checkbox class="webhook-form__include-body" v-model="chatbot.notificationOnly" :label="$t('chatbot.notification_only_label')" hide-details="hide-details"></v-checkbox>
    <p class="mt-4 text--secondary" v-t="'chatbot.event_kind_helptext'"></p>
    <v-checkbox class="webhook-form__event-kind" hide-details="hide-details" v-for="kind in kinds" v-model="chatbot.eventKinds" :key="kind" :label="$t('webhook.event_kinds.' + kind)" :value="kind"></v-checkbox>
    <v-card-actions>
      <v-btn v-if="chatbot.id" @click="destroy" v-t="'common.action.delete'"></v-btn>
      <v-spacer></v-spacer>
      <v-btn @click="testConnection" v-t="'chatbot.test_connection'" :loading="testing"></v-btn>
      <v-btn color="primary" @click="submit" v-t="'common.action.save'"></v-btn>
    </v-card-actions>
  </v-card-text>
</v-card>
</template>
