<script lang="coffee">
import EventBus    from '@/shared/services/event_bus'
import AuthService from '@/shared/services/auth_service'
import AppConfig from '@/shared/services/app_config'
import { hardReload } from '@/shared/helpers/window'

export default
  props:
    user: Object
  data: ->
    vars: {name: @name, site_name: AppConfig.theme.site_name}
  methods:
    submit: ->
      if @useRecaptcha
        grecaptcha.execute()
      else
        @submitForm()

    submitForm: (recaptcha) ->
      @user.recaptcha = recaptcha
      if AuthService.validSignup(@vars, @user)
        # EventBus.emit $scope, 'processing'
        AuthService.signUp(@user, hardReload).finally ->
          # EventBus.emit $scope, 'doneProcessing'
  computed:
    recaptchaKey: -> AppConfig.recaptchaKey
    termsUrl:     -> AppConfig.theme.terms_url
    privacyUrl:   -> AppConfig.theme.privacy_url
    name:         -> @user.name
    allow:        ->
      AppConfig.features.app.create_user or AppConfig.pendingIdentity.identity_type?
    useRecaptcha: ->
      # TODO: GK: don't know how the recaptcha stuff works so bypassing it for now
      false
      # @recaptchaKey && !@user.hasToken

</script>
<template lang="pug">
div
  .auth-signup-form(v-if='!allow')
    h2.lmo-h2(v-t="'auth_form.invitation_required'")
  .auth-signup-form(v-if='allow')
    .auth-signup-form__welcome
      auth-avatar(:user='user')
      h2.lmo-h2(v-t="{ path: 'auth_form.welcome', args: { siteName: vars.site_name } }")
      p(v-t="'auth_form.sign_up_helptext'")
    .md-block.auth-signup-form__name
      label(v-t="'auth_form.name'")
      v-text-field.lmo-primary-form-input(type='text', md-autofocus='true', :placeholder="$t('auth_form.name_placeholder')" v-model='vars.name', required='true')
      //- validation_errors(subject='user', field='name')
    .auth-signup-form__consent(v-if='termsUrl')
      v-checkbox.auth-signup-form__legal-accepted(v-model='vars.legalAccepted')
      span(v-t="{ path: 'auth_form.i_accept', args: { termsUrl: termsUrl, privacyUrl: privacyUrl }}")
      //- validation_errors(subject='user', field='legalAccepted')
    v-btn.md-primary.md-raised.auth-signup-form__submit(:disabled='!vars.name || (termsUrl && !vars.legalAccepted)', v-t="'auth_form.create_account'", @click='submit()')
    div(vc-recaptcha='true', size='invisible', key='recaptchaKey', v-if='useRecaptcha', on-success='submitForm(response)')
</template>
<style lang="scss">
</style>
