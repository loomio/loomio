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
      testing: false
    };
  },

  methods: {
    submit() {
      this.chatbot.save()
      .then(() => {
        Flash.success('chatbot.saved');
        EventBus.$emit('closeModal');
      }).catch(b => {
        Flash.error('common.something_went_wrong');
        console.log(this.chatbot.errors);
      });
    },

    destroy() {
      this.chatbot.destroy().then(() => {
        Flash.success('poll_common_delete_modal.success');
        EventBus.$emit('closeModal');
      }).catch(b => {
        Flash.error('common.something_went_wrong');
        console.log(this.chatbot.errors);
      });
    },

    testConnection() {
      this.testing = true;
      Records.remote.post('chatbots/test', {
        server: this.chatbot.server,
        access_token: this.chatbot.accessToken,
        channel: this.chatbot.channel,
        group_name: "group name was here"
      }).finally(() => {
        Flash.success('chatbot.check_for_test_message');
        this.testing = false;
      });
    }
  }
};

</script>
<template lang="pug">
v-card.chatbot-matrix-form
  v-card-title
    h1.text-h5(tabindex="-1" v-t="'chatbot.chatbot'")
    v-spacer
    dismiss-modal-button
  v-card-text
    v-text-field(:label="$t('chatbot.name')" v-model="chatbot.name" hint="The name of your chatroom")
    v-text-field(:label="$t('chatbot.homeserver_url')"  v-model="chatbot.server" hint="https://example.com")
    v-text-field(
      :label="$t('chatbot.access_token')"
      v-model="chatbot.accessToken"
      placeholder="Looks like: syt_cm9ZXJ0Lmd1dGiaWNG9vbWWv_QsMCFvOcUxucxajF_1Ty2"
      hint="Login as the bot user, then find: User menu > All settings > Help & about > Access token")
    v-text-field(
      :label="$t('chatbot.channel')"
      v-model="chatbot.channel"
      placeholder="E.g. #general:example.com or !hZAAvLtRpxPTHIvfLC:example.com"
      hint="As bot user: Room options > Settings > Advanced > Internal room ID")
      
    v-checkbox.webhook-form__include-body(
      v-model="chatbot.notificationOnly", 
      :label="$t('chatbot.notification_only_label')" 
      hide-details)

    p.mt-4.text--secondary(v-t="'chatbot.event_kind_helptext'")

    v-checkbox.webhook-form__event-kind(
      hide-details 
      v-for='kind in kinds' 
      v-model='chatbot.eventKinds' 
      :key="kind" 
      :label="$t('webhook.event_kinds.' + kind)" 
      :value="kind")

    v-card-actions
      v-btn(v-if="chatbot.id" @click='destroy' v-t="'common.action.delete'")
      v-spacer
      //- v-btn(:disabled="!chatbot.accessToken" @click='testConnection' v-t="'chatbot.test_connection'" :loading="testing")
      v-btn(color='primary' @click='submit' v-t="'common.action.save'")
</template>
