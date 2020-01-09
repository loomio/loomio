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
    samlProviderId: null
  mounted: ->
    Records.samlProviders.fetchByGroupId(@$route.params.key)
    .then (res) =>
      @samlProviderId = res.saml_provider_id
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
    h1.headline(v-t="'configure_sso.title'")
    v-spacer
    dismiss-modal-button(:close="close")
  div(v-if="group.subscriptionPlan == 'pp-pro-monthly' || group.subscriptionPlan == 'pp-pro-annual'")
    v-card-text
      p.helptext(v-html="$t('configure_sso.helptext')")
      v-text-field(v-model='idpMetadataUrl' :label="$t('configure_sso.idp_metadata_url')" :placeholder="$t('configure_sso.idp_metadata_url_placeholder')")
    v-card-actions
      v-spacer
      v-btn(color='primary' @click='submit()', v-t="'common.action.save'")
  v-card-text(v-else)
    p.helptext(v-html="$t('configure_sso.helptext')")
    p(v-html="$t('configure_sso.pro_plan_only')")
</template>
