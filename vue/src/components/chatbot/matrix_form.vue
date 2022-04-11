<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import Flash  from '@/shared/services/flash'

export default
  props:
    chatbot: Object

  data: ->
    chatbot: null
    kinds: AppConfig.webhookEventKinds
    testing: false

  methods:
    submit: ->
      @chatbot.save()
      .then =>
        Flash.success 'chatbot.saved'
        @close()
      .catch (b) =>
        console.log @chatbot.errors

    testConnection: ->
      @testing = true
      Records.remote.post('chatbots/test',
        server: @chatbot.server
        access_token: @chatbot.accessToken
        channel: @chatbot.channel
        group_name: "group name was here"
      ).then =>
        Flash.success('chatbot.test_connection_ok')
      , =>
        Flash.error('chatbot.test_connection_bad')
      .finally =>
        @testing = false

</script>
<template lang="pug">
v-card.chatbot-matrix-form
  v-card-title
    h1.headline(tabindex="-1" v-t="'chatbot.chatbot'")
    v-spacer
    dismiss-modal-button
  v-card-text
    loading(v-if="!chatbot")
    template(v-else)
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
      //- v-checkbox.webhook-form__include-body(v-model="chatbot.includeBody" :label="$t('webhook.include_body_label')" hide-details)
      //- p.mt-4.text--secondary(v-t="'webhook.event_kind_helptext'")
      //- v-checkbox.webhook-form__event-kind(hide-details v-for='kind in kinds' v-model='chatbot.eventKinds' :key="kind" :label="$t('webhook.event_kinds.' + kind)" :value="kind")

      v-card-actions
        v-spacer
        v-btn(@click='testConnection' v-t="'chatbot.test_connection'" :loading="testing")
        v-btn(color='primary' @click='submit' v-t="'common.action.save'")
</template>
