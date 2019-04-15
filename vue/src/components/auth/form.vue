<script lang="coffee">
import { listenForLoading } from '@/shared/helpers/listen'
import { getProviderIdentity } from '@/shared/helpers/user'
import AppConfig from '@/shared/services/app_config'

export default
  props:
    user: Object
    preventClose: Boolean
  data: ->
    emailLogin: AppConfig.features.app.email_login
    siteName: AppConfig.theme.site_name
    privacyUrl: AppConfig.theme.privacy_url
    pendingProviderIdentity: getProviderIdentity()
    isDisabled: false
  computed:
    loginComplete: ->
      @user.sentLoginLink or @user.sentPasswordLink
</script>
<template lang="pug">
.auth-form.lmo-slide-animation
  .lmo-disabled-form(v-show='isDisabled')
  .auth-form__logging-in.animated(v-if='!loginComplete')
    .auth-form__email-not-set.animated(v-if='!user.emailStatus')
      auth-provider-form(:user='user')
      auth-email-form(:user='user', v-if='emailLogin')
      .auth-form__privacy-notice.md-caption.lmo-hint-text(v-if='privacyUrl', v-t="{ path: 'auth_form.privacy_notice', args: { siteName: siteName, privacyUrl: privacyUrl } }")
    .auth-form__email-set.animated(v-if='user.emailStatus')
      auth-identity-form.animated(v-if='pendingProviderIdentity && !user.createAccount', :user='user', :identity='pendingProviderIdentity')
      .auth-form__no-pending-identity.animated(v-if='!pendingProviderIdentity || user.createAccount')
        auth-inactive-form.animated(v-if='user.authForm == "inactive"', :user='user')
      //-   auth_signin_form.animated(v-if='user.authForm == "signIn"', :user='user')
      //-   auth_signup_form.animated(v-if='user.authForm == "signUp"', :user='user')
  //- auth_complete.animated(v-if='loginComplete', :user='user')
</template>
<style lang="scss">
</style>
