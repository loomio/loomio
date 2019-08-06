<script lang="coffee">
import Session       from '@/shared/services/session'
import EventBus      from '@/shared/services/event_bus'
import LmoUrlService from '@/shared/services/lmo_url_service'
import { hardReload } from '@/shared/helpers/window'

export default
  props:
    group: Object
    close: Function
    preventClose: Boolean
  methods:
    hasIdentity: -> Session.user().identityFor('slack')

    redirect: ->
      @$router.push({ query: { install_slack: true } })
      hardReload('/slack/oauth')

  created: ->
    setTimeout @redirect, 500 unless @hasIdentity()
</script>
<template lang="pug">
v-card.install-slack-modal.lmo-modal__narrow
  v-card-title
    h1.headline(v-t="'install_slack.modal_title'")
    v-spacer
    dismiss-modal-button(v-if='!preventClose' :close="close")
  install-slack-install-form(v-if='hasIdentity()' :group='group')
  v-card-text(v-if="!hasIdentity()")
    p.lmo-hint-text(v-t="'install_slack.modal_helptext'")
  v-card-actions(v-if="!hasIdentity()" )
    v-spacer
    v-btn(color='primary' @click='redirect()' v-t="'install_slack.login_to_slack'")
</template>


<!-- remove integration button -->
<!--
