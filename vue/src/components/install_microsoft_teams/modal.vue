<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import { submitForm } from '@/shared/helpers/form'

export default
  props:
    close: Function
    group: Object
  data: ->
    groupIdentity: null
  created: ->
    @groupIdentity = Records.groupIdentities.build
      groupId: @group.id
      identityType: 'microsoft'
      eventKinds:
        new_discussion: true
        poll_created: true
        poll_closing_soon: true
        poll_expired: true
        outcome_created: true

    @submit = submitForm @, @groupIdentity,
      prepareFn: =>
        @groupIdentity.customFields.event_kinds = _.map @groupIdentity.eventKinds, (value, key) -> key if value
      flashSuccess: 'install_microsoft.form.webhook_installed'
      successCallback: -> EventBus.$emit 'closeModal'
</script>
<template lang="pug">
v-card.install-microsoft-modal
  v-card-title
    h1.headline(v-t="'install_microsoft.modal_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text.install-microsoft-form
    p.lmo-hint-text(v-t="'install_microsoft.form.webhook_helptext'")
    v-text-field#microsoft-webhook-url.discussion-form__title-input(v-model='groupIdentity.webhookUrl' :placeholder="$t('install_microsoft.form.webhook_placeholder')" maxlength='255')
      div(slot="label")
        span(v-html="$t('install_microsoft.form.webhook_label')")
    validation-errors(:subject='groupIdentity' field='webhookUrl')
    p.lmo-hint-text(v-t="'install_microsoft.form.event_kind_helptext'")
    v-checkbox.install-microsoft-form__event-kinds(v-for='kind in groupIdentity.constructor.validEventKinds' v-model='groupIdentity.eventKinds[kind]' :key="kind")
      div(slot="label")
        span(v-t="'install_microsoft.event_kinds.' + kind")
  v-card-actions
    v-spacer
    v-btn(color='primary' @click='submit()', v-t="'common.action.save'")
</template>
