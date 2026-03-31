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
      creatingDatabase: false,
      useExistingDatabase: !!this.chatbot.channel,
      pageId: ''
    };
  },

  methods: {
    submit() {
      this.chatbot.save()
      .then(() => {
        Flash.success('chatbot.integration_saved');
        EventBus.$emit('closeModal');
      }).catch(b => {
        Flash.warning('common.check_for_errors_and_try_again');
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

    createDatabase() {
      this.creatingDatabase = true;
      Records.remote.post('chatbots/create_notion_database', {
        access_token: this.chatbot.accessToken,
        page_id: this.pageId,
        title: this.chatbot.name || 'Loomio Decisions'
      }).then((response) => {
        this.chatbot.channel = response.database_id;
        Flash.success('chatbot.notion_database_created');
      }).catch(() => {
        Flash.error('chatbot.notion_database_create_failed');
      }).finally(() => {
        this.creatingDatabase = false;
      });
    },

    testConnection() {
      this.testing = true;
      Records.remote.post('chatbots/check', {
        kind: 'notion',
        access_token: this.chatbot.accessToken,
        channel: this.chatbot.channel
      }).then(() => {
        Flash.success('chatbot.notion_test_success');
      }).catch(() => {
        Flash.error('common.something_went_wrong');
      }).finally(() => {
        this.testing = false;
      });
    }
  }
};

</script>
<template lang="pug">
v-card.chatbot-notion-form(:title="$t('chatbot.notion')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    p.text-body-2.text-medium-emphasis {{ $t('chatbot.notion_helptext') }}

    v-text-field(
      :label="$t('chatbot.integration_name')"
      v-model="chatbot.name"
      autocomplete="off")
    validation-errors(:subject="chatbot" field="name")

    v-text-field(
      :label="$t('chatbot.notion_api_token')"
      v-model="chatbot.accessToken"
      autocomplete="off"
      placeholder="ntn_..."
      :hint="$t('chatbot.notion_api_token_hint')")
    validation-errors(:subject="chatbot" field="access_token")

    v-radio-group.mt-2(v-if="!chatbot.id" v-model="useExistingDatabase" inline hide-details)
      v-radio(:label="$t('chatbot.notion_create_new_database')" :value="false")
      v-radio(:label="$t('chatbot.notion_use_existing_database')" :value="true")

    template(v-if="useExistingDatabase || chatbot.id")
      v-text-field(
        :label="$t('chatbot.notion_database_id')"
        v-model="chatbot.channel"
        autocomplete="off"
        placeholder="e.g. 8a3b5c7d-1234-5678-9abc-def012345678"
        :hint="$t('chatbot.notion_database_id_hint')")
      validation-errors(:subject="chatbot" field="channel")

    template(v-if="!useExistingDatabase && !chatbot.id")
      v-text-field(
        :label="$t('chatbot.notion_page_id')"
        v-model="pageId"
        autocomplete="off"
        placeholder="e.g. 8a3b5c7d-1234-5678-9abc-def012345678"
        :hint="$t('chatbot.notion_page_id_hint')")
      v-btn.mt-2(
        @click="createDatabase"
        :loading="creatingDatabase"
        :disabled="!chatbot.accessToken || !pageId"
        variant="tonal")
        span(v-t="'chatbot.notion_create_database_btn'")

    v-checkbox.webhook-form__include-body(
      v-model="chatbot.notificationOnly",
      :label="$t('chatbot.integration_notification_only_label')"
      hide-details)

    p.mt-4.text-medium-emphasis(v-t="'chatbot.integration_event_kind_helptext'")

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
    v-btn(v-if="chatbot.channel" @click='testConnection' v-t="'chatbot.test_connection'" :loading="testing")
    v-btn(color='primary' @click='submit' :disabled="!chatbot.channel" v-t="'common.action.save'")
</template>
