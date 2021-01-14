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
    webhooks: []
    loading: true

  mounted: ->
    Records.webhooks.fetch(params: {group_id: @group.id}).then => @loading = false
    @watchRecords
      collections: ["webhooks"]
      query: (records) =>
        @webhooks = records.webhooks.find(groupId: @group.id)

  methods:
    addAction: (group) ->
      WebhookService.addAction(group)
    webhookActions: (webhook) ->
      WebhookService.webhookActions(webhook)

</script>
<template lang="pug">
v-card.webhook-list
  v-card-title
    h1.headline(tabindex="-1" v-t="'webhook.integrations'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    p.lmo-hint-text(v-t="'webhook.subtitle'")
    loading(v-if="loading")
    v-list(v-if="!loading")
      v-list-item(v-for="webhook in webhooks" :key="webhook.id")
        v-list-item-content
          v-list-item-title {{webhook.name}}
        v-list-item-action
          action-menu(:actions="webhookActions(webhook)")
  v-card-actions
    v-spacer
    v-btn(color='primary' @click='addAction(group).perform()' v-t="addAction(group).name")
</template>
