<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import AppConfig from '@/shared/services/app_config'
import WebhookService from '@/shared/services/webhook_service'
import Records from '@/shared/services/records'
import Flash  from '@/shared/services/flash'
import openModal from '@/shared/helpers/open_modal'

export default
  props:
    close: Function
    group: Object

  data: ->
    chatbot: null

  mounted: ->
    Records.chatbots.fetch(params: {group_id: @group.id}).then =>
      @chatbot = Records.chatbots.findOrNull(groupId: @group.id)
      if !@chatbot
        @chatbot = Records.chatbots.build(groupId: @group.id)

  methods:
    save: ->
      WebhookService.addAction(group)

</script>
<template lang="pug">
v-card.webhook-list
  v-card-title
    h1.headline(tabindex="-1" v-t="'chatbot.chatbot'") Chatbot
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    loading(v-if="!chatbot")
    template(v-else)
      v-text-field(:label="$t('chatbot.homeserver_url')"  v-model="chatbot.server")
      v-text-field(:label="$t('chatbot.username')" v-model="chatbot.username")
      v-text-field(:label="$t('chatbot.password')" v-model="chatbot.password")
      v-text-field(:label="$t('chatbot.channel')" v-model="chatbot.channel")
      v-card-actions
        v-spacer
        v-btn(color='primary' @click='save' v-t="'common.action.save'")
</template>
