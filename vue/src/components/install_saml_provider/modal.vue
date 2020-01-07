<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Flash  from '@/shared/services/flash'
import RestfulClient from '@/shared/record_store/restful_client'
import { onError } from '@/shared/helpers/form'

export default
  props:
    close: Function
    group: Object
  data: ->
    idpMetadataUrl: ''
  methods:
    submit: ->
      remote = new RestfulClient('saml_providers')
      remote.create(idp_metadata_url: @idpMetadataUrl, group_id: @group.id)
      .then =>
        Flash.success 'install_microsoft.form.webhook_installed'
        @close()
      .catch =>
        alert("boo")
</script>
<template lang="pug">
v-card.install-microsoft-modal
  v-card-title
    h1.headline(v-t="'install_saml_provider.title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    //- p.lmo-hint-text(v-html="$t('install_microsoft.form.webhook_helptext')")
    v-text-field(v-model='idpMetadataUrl')

  v-card-actions
    v-spacer
    v-btn(color='primary' @click='submit()', v-t="'common.action.save'")
</template>
