<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import AuthService   from '@/shared/services/auth_service'
import Session from '@/shared/services/session'

export default
  props:
    preventClose: Boolean
    close: Function

  data: ->
    siteName: AppConfig.theme.site_name
    titleKey: 'auth_form.sign_in_to_loomio'
    user: Records.users.build(createAccount: false)
    isDisabled: false
    pendingProviderIdentity: Session.providerIdentity()

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
.auth-modal
  auth-form(v-if="!user.authForm" :user='user')
  auth-signin-form(v-if='user.authForm == "signIn"' :user='user')
  auth-signup-form(v-if='user.authForm == "signUp"' :user='user')
  auth-identity-form(v-if='user.authForm == "identity"' :user='user' :identity='pendingProviderIdentity')
  auth-complete(v-if='user.authForm == "complete"', :user='user')
</template>
