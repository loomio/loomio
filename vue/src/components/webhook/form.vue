<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Flash  from '@/shared/services/flash'

export default
  props:
    close: Function
    group: Object

  data: ->
    webhook: Records.webhooks.build
      groupId: @group.id
      eventKinds: Records.webhooks.model.validEventKinds

  methods:
    submit: ->
      @webhook.save()
      .then =>
        Flash.success 'webhook.success'
        @close()
</script>
<template lang="pug">
v-card.webhook-form
  v-card-title
    h1.headline(v-t="'webhook.form_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text.install-webhook-form
    p.lmo-hint-text(v-t="'webhook.subtitle'")
    p.lmo-hint-text(v-t="{path: 'webhook.we_have_guides', args: {url: 'https://help.loomio.org/en/user_manual/groups/integrations/'}}")
    v-text-field.webhook-form__url(type="url" v-model='webhook.url' :label="'webhook.form.url_label'" :placeholder="$t('webhook.form.webhook_placeholder')")
    validation-errors(:subject='webhook' field='url')
    v-text-field.webhook-form__name(v-model='webhook.name' :label="'webhook.form.name_label'" :placeholder="$t('webhook.form.name_placeholder')")
    validation-errors(:subject='webhook' field='name')
    p.lmo-hint-text(v-t="'webhook.form.event_kind_helptext'")
    v-checkbox.webhook-form__event-kind(hide-details v-for='kind in webhook.constructor.validEventKinds' v-model='webhook.eventKinds' :key="kind" :label="$t('install_microsoft.event_kinds.' + kind)" :value="kind")
  v-card-actions
    v-spacer
    v-btn(color='primary' @click='submit()', v-t="'common.action.save'")
</template>
