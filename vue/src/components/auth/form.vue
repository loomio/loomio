<script lang="coffee">
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
    pendingGroup: null

  created: ->
    @watchRecords
      key: 'authForm'
      collections: ['groups']
      query: (store) =>
        return unless AppConfig.pending_identity
        @pendingGroup = store.groups.find(AppConfig.pending_identity.group_id)

  computed:
    loginComplete: ->
      @user.sentLoginLink or @user.sentPasswordLink

    pendingDiscussion: ->
      AppConfig.pending_identity.identity_type == 'discussion_reader'

    pendingPoll: ->
      AppConfig.pending_identity.identity_type == 'stance'

</script>
<template lang="pug">
.auth-form
  submit-overlay(:value='isDisabled')
  .auth-form__logging-in(v-if='!loginComplete')
    .auth-form__email-not-set(v-if='!user.emailStatus')
      p.headline.text-center(v-if="pendingGroup" v-t="{path: 'auth_form.youre_invited', args: {group_name: pendingGroup.name}}")
      p.headline.text-center(v-if="pendingDiscussion" v-t="'auth_form.youre_invited_discussion'")
      p.headline.text-center(v-if="pendingPoll" v-t="'auth_form.youre_invited_poll'")
      auth-provider-form(:user='user')
      auth-email-form(:user='user' v-if='emailLogin')
      .text-center.caption.mt-4
        a.auth-form__sign-in-help(href="https://help.loomio.org/en/user_manual/users/sign_in/" target="_blank" v-t="'auth_form.sign_in_help'")
      .auth-form__privacy-notice.caption.text-center.mt-4(v-if='privacyUrl' v-html="$t('auth_form.privacy_notice', { siteName: siteName, privacyUrl: privacyUrl })")
    .auth-form__email-set(v-if='user.emailStatus')
      auth-identity-form(v-if='pendingProviderIdentity && !user.createAccount' :user='user' :identity='pendingProviderIdentity')
      .auth-form__no-pending-identity(v-if='!pendingProviderIdentity || user.createAccount')
        auth-inactive-form(v-if='user.authForm == "inactive"' :user='user')
        auth-signin-form(v-if='user.authForm == "signIn"' :user='user')
        auth-signup-form(v-if='user.authForm == "signUp"' :user='user')
  auth-complete(v-if='loginComplete', :user='user')
</template>
