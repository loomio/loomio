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
    isDisabled: false
    pendingGroup: null

  created: ->
    @watchRecords
      key: 'authForm'
      collections: ['groups']
      query: (store) =>
        @pendingGroup = store.groups.find(@pendingIdentity.group_id)

  computed:
    loginComplete: ->
      @user.sentLoginLink or @user.sentPasswordLink

    pendingDiscussion: ->
      @pendingIdentity.identity_type == 'discussion_reader'

    pendingPoll: ->
      @pendingIdentity.identity_type == 'stance'

    pendingIdentity: ->
      (AppConfig.pending_identity || {})

</script>
<template lang="pug">
v-card.auth-form
  v-card-title
    h1.headline(tabindex="-1" role="status" aria-live="polite" v-t="{ path: 'auth_form.sign_in_to_loomio', args: { site_name: siteName } }")
    v-spacer
    dismiss-modal-button(v-if='!preventClose')
  v-sheet.py-4.pb-4
    p.headline.text-center(v-if="pendingGroup" v-t="{path: 'auth_form.youre_invited', args: {group_name: pendingGroup.name}}")
    p.headline.text-center(v-if="pendingDiscussion" v-t="'auth_form.youre_invited_discussion'")
    p.headline.text-center(v-if="pendingPoll" v-t="'auth_form.youre_invited_poll'")
    auth-provider-form(:user='user')
    auth-email-form(:user='user' v-if='emailLogin')
    .text-center.caption.mt-4
      a.auth-form__sign-in-help(href="https://help.loomio.org/en/user_manual/users/sign_in/" target="_blank" v-t="'auth_form.sign_in_help'")
    .auth-form__privacy-notice.caption.text-center.mt-4(v-if='privacyUrl' v-html="$t('auth_form.privacy_notice', { siteName: siteName, privacyUrl: privacyUrl })")
</template>
