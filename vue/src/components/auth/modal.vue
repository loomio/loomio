<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import AuthService from '@/shared/services/auth_service'

export default
  props:
    preventClose: Boolean
    close: Function

  data: ->
    siteName: AppConfig.theme.site_name
    user: Records.users.build()
    isDisabled: false

  mounted: ->
    AuthService.applyEmailStatus(@user, AppConfig.pendingIdentity)

  methods:
    back: -> @user.emailStatus = null

  computed:
    showBackButton: ->
      @user.emailStatus and
      !@user.sentLoginLink and
      !@user.sentPasswordLink
</script>
<template lang="pug">
v-card
  .lmo-disabled-form(v-show='isDisabled')
  span {{user}}
  v-card-title
    i.mdi.mdi-lock-open(ng-if='!showBackButton()')
    a.auth-modal__back(ng-click='back()', ng-if='showBackButton()')
      i.mdi.mdi-keyboard-backspace
    h1.lmo-h1(v-t="{ path: 'auth_form.sign_in_to_loomio', args: { site_name: siteName } }")
    dismiss-modal-button(v-if='!preventClose' :close="close")
    div(v-if='preventClose')
  v-card-text
    auth-form(:user='user')
</template>
<style lang="scss">
</style>
