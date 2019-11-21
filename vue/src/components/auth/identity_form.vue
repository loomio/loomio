<script lang="coffee">
import EventBus    from '@/shared/services/event_bus'
import AuthService from '@/shared/services/auth_service'
import AppConfig from '@/shared/services/app_config'

export default
  props:
    user: Object
    identity: Object
  methods:
    submit: ->
      # EventBus.emit $scope, 'processing'
      @user.email = @email
      AuthService.sendLoginLink(@user).then (->), ->
        @user.errors = {email: [@$t('auth_form.email_not_found')]}
      .finally ->
        console.log 'doneProcessing'
        # EventBus.emit $scope, 'doneProcessing'
    createAccount: -> @user.createAccount = true
  computed:
    siteName: -> AppConfig.theme.site_name

</script>
<template lang="pug">
.auth-identity-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  .mb-4.text-center
    auth-avatar(:user='user')
    h2.headline(v-t="{ path: 'auth_form.hello', args: { name: user.name || user.email } }")
  .auth-identity-form__options
    .auth-identity-form__new-account.mb-8
      p(v-t="{ path: 'auth_form.new_to_loomio', args: { site_name: siteName } }")
      v-btn(color="primary" @click='createAccount()', v-t="'auth_form.create_account'")
    .auth-identity-form__existing-account
      p(v-t="{ path: 'auth_form.already_a_user', args: { site_name: siteName }}")
      .auth-email-form__email
        label(v-t="'auth_form.email'")
        v-text-field#email.lmo-primary-form-input(name='email' type='text' v-autofocus='true' :placeholder="$t('auth_form.email_address_of_existing_account')" v-model='email')
        validation-errors(:subject='user' :field='email')
      v-btn(@click='submit()' v-t="'auth_form.link_accounts'")
</template>
