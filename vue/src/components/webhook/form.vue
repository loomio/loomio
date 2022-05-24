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
    permissions: ['show_discussion', 'create_discussion', 'show_poll', 'create_poll', 'read_memberships', 'manage_memberships']

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
      h1.headline(tabindex="-1" v-t="!webhook.id ? 'webhook.add_api_key' : 'webhook.edit_api_key'")
      v-spacer
      dismiss-modal-button(:close="close")
    v-card-text.install-webhook-form
      v-text-field.webhook-form__name(v-model='webhook.name' required :label="$t('webhook.name_label')" :placeholder="$t('webhook.name_placeholder')")
      validation-errors(:subject='webhook' field='name')
      a(v-if="webhook.id" :href="docsUrl(webhook.token)" v-t="'webhook.show_docs'" target="_blank")
      p(v-if="!webhook.id"  v-t="'webhook.save_to_show_docs'")
      p.pt-4.text--secondary(v-t="'webhook.permissions_explaination'")
      v-checkbox.webhook-form__permission(hide-details v-for='permission in permissions' v-model='webhook.permissions' :key="permission" :label="$t('webhook.permissions.' + permission)" :value="permission")

    v-card-actions
      v-spacer
      v-btn(color='primary' type="submit" v-t="'common.action.save'" :loading="webhook.processing")
</template>
