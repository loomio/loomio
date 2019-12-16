<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import GroupIdentityModel from '@/shared/models/group_identity_model'
import Flash  from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'

export default
  props:
    close: Function
    group: Object
  data: ->
    groupIdentity: Records.groupIdentities.build
      groupId: @group.id
      identityType: 'microsoft'
      customFields:
        event_kinds: GroupIdentityModel.validEventKinds
  methods:
    submit: ->
      @groupIdentity.save()
      .then =>
        Flash.success 'install_microsoft.form.webhook_installed'
        @close()
      .catch onError(@groupIdentity)
</script>
<template lang="pug">
v-card.install-microsoft-modal
  v-card-title
    h1.headline(v-t="'install_microsoft.modal_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text.install-microsoft-form
    p.lmo-hint-text(v-html="$t('install_microsoft.form.webhook_helptext')")
    v-text-field#microsoft-webhook-url.discussion-form__title-input(v-model='groupIdentity.webhookUrl' :placeholder="$t('install_microsoft.form.webhook_placeholder')" maxlength='255')
      div(slot="label")
        span(v-html="$t('install_microsoft.form.webhook_label')")
    validation-errors(:subject='groupIdentity' field='webhookUrl')
    p.lmo-hint-text(v-t="'install_microsoft.form.event_kind_helptext'")
    v-checkbox.install-microsoft-form__event-kinds(hide-details v-for='kind in groupIdentity.constructor.validEventKinds' v-model='groupIdentity.customFields.event_kinds' :key="kind" :label="$t('install_microsoft.event_kinds.' + kind)" :value="kind")
  v-card-actions
    v-spacer
    v-btn(color='primary' @click='submit()', v-t="'common.action.save'")
</template>
