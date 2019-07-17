<script lang="coffee">
import { listenForLoading } from '@/shared/helpers/listen'
import AppConfig from '@/shared/services/app_config'
import Session from '@/shared/services/session'

export default
  props:
    user: Object
    preventClose: Boolean
  data: ->
    emailLogin: AppConfig.features.app.email_login
    siteName: AppConfig.theme.site_name
    privacyUrl: AppConfig.theme.privacy_url
    pendingProviderIdentity: Session.providerIdentity()
    isDisabled: false
  computed:
    loginComplete: ->
      @user.sentLoginLink or @user.sentPasswordLink
</script>
<template lang="pug">
.auth-form
  .lmo-disabled-form(v-show='isDisabled')
  .auth-form__logging-in(v-if='!loginComplete')
    .auth-form__email-not-set(v-if='!user.emailStatus')
      p.text-xs-center Loomio is a place to have discussions and collaborate
      auth-provider-form(:user='user')
      auth-email-form(:user='user' v-if='emailLogin')
      .auth-form__privacy-notice.caption.text-xs-center.mt-3(v-if='privacyUrl' v-html="$t('auth_form.privacy_notice', { siteName: siteName, privacyUrl: privacyUrl })")
    .auth-form__email-set(v-if='user.emailStatus')
      auth-identity-form(v-if='pendingProviderIdentity && !user.createAccount' :user='user' :identity='pendingProviderIdentity')
      .auth-form__no-pending-identity(v-if='!pendingProviderIdentity || user.createAccount')
        auth-inactive-form(v-if='user.authForm == "inactive"' :user='user')
        auth-signin-form(v-if='user.authForm == "signIn"' :user='user')
        auth-signup-form(v-if='user.authForm == "signUp"' :user='user')
  auth-complete(v-if='loginComplete', :user='user')
</template>
