<script lang="coffee">
import Session       from '@/shared/services/session'
import EventBus      from '@/shared/services/event_bus'
import LmoUrlService from '@/shared/services/lmo_url_service'

export default
  props:
    group: Object
    close: Function
    preventClose: Boolean
  methods:
    hasIdentity: -> Session.user().identityFor('slack')

    redirect: ->
      @$router.push({path: 'oauth', query: { install_slack: true }})

  created: ->
    setTimeout @redirect, 500 unless @hasIdentity()
</script>
<template lang="pug">
v-card.install-slack-modal.lmo-modal__narrow
  v-card-title
    h1.lmo-h1(v-t="'install_slack.modal_title'")
    dismiss-modal-button(v-if='!preventClose' :close="close")
  v-card-text
    install-slack-form(v-if='hasIdentity()', :group='group')
    .install-slack-form__redirect(@click='redirect()', v-if='!hasIdentity')
      auth-avatar
      p.lmo-hint-text(v-t="'install_slack.modal_helptext'")
  v-card-actions
    v-btn(@click='redirect()', v-t="'install_slack.login_to_slack'")
</template>
