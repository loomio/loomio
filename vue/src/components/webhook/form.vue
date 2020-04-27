<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import Flash  from '@/shared/services/flash'

export default
  props:
    close: Function
    group: Object
    model: Object

  data: ->
    webhook: @model || Records.webhooks.build(groupId: @group.id)
    kinds: AppConfig.webhookEventKinds
    formats: [
      {text: @$t('webhook.formats.markdown'), value: "markdown"}
      {text: @$t('webhook.formats.microsoft'), value: "microsoft"}
      {text: @$t('webhook.formats.slack'), value: "slack"}
    ]

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
    h1.headline(v-t="'webhook.add_webhook'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text.install-webhook-form
    v-text-field.webhook-form__name(v-model='webhook.name' :label="$t('webhook.name_label')" :placeholder="$t('webhook.name_placeholder')")
    v-select(v-model="webhook.format" :items="formats" :label="$t('webhook.format')")
    validation-errors(:subject='webhook' field='name')
    v-text-field.webhook-form__url(type="url" v-model='webhook.url' :label="$t('webhook.url_label')" :placeholder="$t('webhook.url_placeholder')")
    validation-errors(:subject='webhook' field='url')
    v-checkbox.webhook-form__include-body(v-model="webhook.includeBody" :label="$t('webhook.include_body_label')" hide-details)
    //- v-checkbox.webhook-form__include-body(v-if="group.subgroupsCount" v-model="webhook.includeSubgroups" :label="$t('webhook.include_subgroups_label')" hide-details)
    p.mt-4.lmo-hint-text(v-t="'webhook.event_kind_helptext'")
    v-checkbox.webhook-form__event-kind(hide-details v-for='kind in kinds' v-model='webhook.eventKinds' :key="kind" :label="$t('webhook.event_kinds.' + kind)" :value="kind")

  v-card-actions
    v-spacer
    v-btn(color='primary' @click='submit()' v-t="'common.action.save'" :loading="webhook.processing")
</template>
