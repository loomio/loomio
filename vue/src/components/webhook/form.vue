<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import Flash  from '@/shared/services/flash'

export default
  props:
    close: Function
    webhook: Object

  data: ->
    tab: 'webhook'
    kinds: AppConfig.webhookEventKinds
    permissions: ['create_discussion', 'create_poll', 'read_memberships']
    formats: [
      {text: @$t('webhook.formats.markdown'), value: "markdown"}
      {text: @$t('webhook.formats.microsoft'), value: "microsoft"}
      {text: @$t('webhook.formats.slack'), value: "slack"}
    ]

  methods:
    docsUrl: (key) ->
      AppConfig.baseUrl + "help/api?api_key=#{key}"

    submit: ->
      @webhook.save()
      .then =>
        Flash.success 'webhook.success'
        @close()
      .catch (b) =>
        console.log @webhook.errors
</script>
<template lang="pug">
v-card.webhook-form
  form(@submit.prevent="submit")
    v-card-title
      h1.headline(tabindex="-1" v-t="!webhook.id ? 'webhook.add_integration' : 'webhook.edit_integration'")
      v-spacer
      dismiss-modal-button(:close="close")
    v-card-text.install-webhook-form
      v-text-field.webhook-form__name(v-model='webhook.name' required :label="$t('webhook.name_label')" :placeholder="$t('webhook.name_placeholder')")
      validation-errors(:subject='webhook' field='name')
      v-tabs(v-model="tab")
        v-tab(v-t="'webhook.webhook'" key="webhook")
        v-tab(v-t="'webhook.api'" key="api")
      v-tabs-items(v-model="tab")
        v-tab-item(key="webhook")
          p.pt-4.text--secondary(v-html="$t('webhook.we_have_guides', {url: 'https://help.loomio.org/en/user_manual/groups/integrations/'})")
          v-text-field.webhook-form__url(type="url" v-model='webhook.url' :label="$t('webhook.url_label')" :placeholder="$t('webhook.url_placeholder')")
          validation-errors(:subject='webhook' field='url')
          v-select(v-model="webhook.format" :items="formats" :label="$t('webhook.format')")
          validation-errors(:subject='webhook' field='name')
          v-checkbox.webhook-form__include-body(v-model="webhook.includeBody" :label="$t('webhook.include_body_label')" hide-details)
          //- v-checkbox.webhook-form__include-body(v-if="group.subgroupsCount" v-model="webhook.includeSubgroups" :label="$t('webhook.include_subgroups_label')" hide-details)
          p.mt-4.text--secondary(v-t="'webhook.event_kind_helptext'")
          v-checkbox.webhook-form__event-kind(hide-details v-for='kind in kinds' v-model='webhook.eventKinds' :key="kind" :label="$t('webhook.event_kinds.' + kind)" :value="kind")
        v-tab-item(key="api")
          a(:href="docsUrl(webhook.token)" v-t="'webhook.show_docs'" target="_blank")
          p.pt-4.text--secondary(v-t="'webhook.permissions_explaination'")
          v-checkbox.webhook-form__permission(hide-details v-for='permission in permissions' v-model='webhook.permissions' :key="permission" :label="$t('webhook.permissions.' + permission)" :value="permission")

    v-card-actions
      v-spacer
      v-btn(color='primary' type="submit" v-t="'common.action.save'" :loading="webhook.processing")
</template>
