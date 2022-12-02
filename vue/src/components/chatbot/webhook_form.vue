<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import Flash  from '@/shared/services/flash'

export default
  props:
    chatbot: Object

  data: ->
    kinds: AppConfig.webhookEventKinds
    testing: false
    formats: [
      {text: @$t('webhook.formats.markdown'), value: "markdown"}
      {text: @$t('webhook.formats.microsoft'), value: "microsoft"}
      {text: @$t('webhook.formats.slack'), value: "slack"}
      {text: @$t('webhook.formats.discord'), value: "discord"}
    ]

  methods:
    destroy: ->
      @chatbot.destroy().then =>
        Flash.success 'poll_common_delete_modal.success'
        EventBus.$emit('closeModal')
      .catch (b) =>
        Flash.error 'common.something_went_wrong'
        console.log @chatbot.errors
        
    submit: ->
      @chatbot.save()
      .then =>
        Flash.success 'chatbot.saved'
        EventBus.$emit('closeModal')
      .catch (b) =>
        Flash.warning 'common.check_for_errors_and_try_again'

    testConnection: ->
      @testing = true
      Records.remote.post('chatbots/test',
        server: @chatbot.server
        kind: 'slack_webhook'
      ).finally =>
        Flash.success('chatbot.check_for_test_message')
        @testing = false

  computed:
    url: ->
      switch @chatbot.webhookKind
        when "slack" then "https://help.loomio.com/en/user_manual/groups/integrations/slack"
        when "discord" then "https://help.loomio.com/en/user_manual/groups/integrations/discord"
        when "microsoft" then "https://help.loomio.com/en/user_manual/groups/integrations/microsoft_teams"
        when "mattermost" then "https://help.loomio.com/en/user_manual/groups/integrations/mattermost"

</script>
<template lang="pug">
v-card.chatbot-matrix-form
  v-card-title
    h1.headline(tabindex="-1")
      span Webhook
      space
      span(v-t="'chatbot.chatbot'")
    v-spacer
    dismiss-modal-button
  v-card-text
    v-text-field(
      :label="$t('chatbot.name')"
      v-model="chatbot.name"
      hint="The name of your chatroom")
    validation-errors(:subject="chatbot" field="name")
    v-text-field(
      :label="$t('chatbot.webhook_url')"
      v-model="chatbot.server"
      hint="Looks like: https://hooks.example.com/services/abc/xyz/123")
    validation-errors(:subject="chatbot" field="server")

    p.mt-2.mb-2(v-html="$t('webhook.we_have_guides', {url: url})")
    //- v-select(v-model="chatbot.webhookKind" :items="formats" :label="$t('webhook.format')")

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
      v-btn(@click='testConnection', v-t="'chatbot.test_connection'", :loading="testing")
      v-btn(color='primary' @click='submit' v-t="'common.action.save'")
</template>
