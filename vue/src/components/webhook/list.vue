<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import AppConfig from '@/shared/services/app_config'
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
    add: ->
      openModal
        component: 'WebhookForm'
        props:
          group: @group
    edit: (webhook)->
      openModal
        component: 'WebhookForm'
        props:
          group: @group
          model: webhook

    confirmRemove: (webhook) ->
      openModal
        component: 'ConfirmModal'
        props:
          confirm:
            submit: webhook.destroy
            text:
              title: 'webhook.remove'
              raw_helptext: @$t('webhook.confirm_remove', {name: webhook.name})
              flash: 'webhook.removed'

</script>
<template lang="pug">
v-card.webhook-list
  v-card-title
    h1.headline(v-t="'webhook.webhooks'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    p.lmo-hint-text(v-t="'webhook.subtitle'")
    p.lmo-hint-text(v-html="$t('webhook.we_have_guides', {url: 'https://help.loomio.org/en/user_manual/groups/integrations/'})")
    loading(v-if="loading")
    v-list(v-if="!loading")
      v-list-item(v-for="webhook in webhooks" :key="webhook.id")
        v-list-item-content
          v-list-item-title {{webhook.name}}
        v-list-item-action
          v-btn(icon @click="edit(webhook)" :title="$t('common.action.edit')")
            v-icon(color="accent") mdi-pencil
        v-list-item-action
          v-btn(icon @click="confirmRemove(webhook)" :title="$t('common.action.delete')")
            v-icon(color="warning") mdi-delete
  v-card-actions
    v-spacer
    v-btn(color='primary' @click='add()', v-t="'webhook.add_webhook'")
</template>
