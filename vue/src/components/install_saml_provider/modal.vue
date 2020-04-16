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
    remote: new RestfulClient('saml_providers')
    loading: true

  mounted: ->
    Records.samlProviders.fetch(params: {group_id: @group.id})
    .then (data) =>
      @idpMetadataUrl = data.idp_metadata_url
      @samlProviderId = data.saml_provider_id
      @spMetadataUrl = data.sp_metadata_url
    .catch =>
      # all good
    .finally =>
      @loading = false

  methods:
    submit: ->
      @loading = true
      @remote.create(idp_metadata_url: @idpMetadataUrl, group_id: @group.id)
      .then =>
        Flash.success 'configure_sso.success'
        @close()
      .catch =>
        Flash.error 'configure_sso.invalid_idp_metadata_url'
      .finally =>
        @loading = false

    destroy: ->
      @remote.destroy(@samlProviderId, group_id: @group.id)
      .then =>
        Flash.success 'configure_sso.destroyed'
        @close()
      .catch => alert "Something went wrong. Email contact@loomio.org for support."

  computed:
    isProPlan: ->
      @group.subscriptionPlan == 'pp-pro-monthly' || @group.subscriptionPlan == 'pp-pro-annual'

</script>
<template lang="pug">
v-card.install-saml-modal
  v-card-title
    h1.headline(v-t="'configure_sso.title'")
    v-spacer
    dismiss-modal-button(:close="close")
  loading(:until="!loading")
  div(v-if="samlProviderId")
    v-card-text
      p(v-t="'configure_sso.enabled'")
      p
        span(v-t="'configure_sso.idp_metadata_url'")
        span :
        space
        a(:href="idpMetadataUrl" target="_blank") {{idpMetadataUrl}}
      p
        span(v-t="'configure_sso.sp_metadata_url'")
        span :
        space
        a(:href="spMetadataUrl + '.xml'" target="_blank") {{spMetadataUrl}}
    v-card-actions
      v-spacer
      v-btn(color='primary' @click='destroy()' v-t="'common.action.remove'")
  div(v-else)
    v-card-text(v-if="!loading")
      p.helptext(v-html="$t('configure_sso.helptext')")
      p(v-if="!isProPlan" v-html="$t('configure_sso.pro_plan_only')")
      v-text-field(v-if="isProPlan" v-model='idpMetadataUrl' :label="$t('configure_sso.idp_metadata_url')" :placeholder="$t('configure_sso.idp_metadata_url_placeholder')")
      p(v-t="'configure_sso.warning_helptext'")
    v-card-actions(v-if="!loading && isProPlan")
      v-spacer
      v-btn(color='primary' @click='submit()' v-t="'common.action.save'")
</template>
