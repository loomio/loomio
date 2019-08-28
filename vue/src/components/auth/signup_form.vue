<script lang="coffee">
import EventBus    from '@/shared/services/event_bus'
import AuthService from '@/shared/services/auth_service'
import AppConfig from '@/shared/services/app_config'
import Session from '@/shared/services/session'
import AuthModalMixin from '@/mixins/auth_modal'
import Flash from '@/shared/services/flash'
import VueRecaptcha from 'vue-recaptcha';
import openModal      from '@/shared/helpers/open_modal'
import { hardReload } from '@/shared/helpers/window'

export default
  components:
    'v-recaptcha': VueRecaptcha
  mixins: [AuthModalMixin]
  props:
    user: Object
  data: ->
    vars: {name: @name, site_name: AppConfig.theme.site_name}
  methods:
    submit: ->
      if @useRecaptcha
        @$refs.invisibleRecaptcha.execute()
      else
        @submitForm()

    submitForm: (recaptcha) ->
      @user.recaptcha = recaptcha
      if AuthService.validSignup(@vars, @user)
        # EventBus.emit $scope, 'processing'
        AuthService.signUp(@user).finally ->
          # EventBus.emit $scope, 'doneProcessing'
  computed:
    recaptchaKey: -> AppConfig.recaptchaKey
    termsUrl: -> AppConfig.theme.terms_url
    privacyUrl: -> AppConfig.theme.privacy_url
    name: -> @user.name
    allow: ->
      AppConfig.features.app.create_user or AppConfig.pendingIdentity.identity_type?
    useRecaptcha: ->
      @recaptchaKey && !@user.hasToken

</script>
<template lang="pug">
div(@keyup.ctrl.enter="submit()" @keydown.meta.enter="submit()" @keydown.enter="submit()")
  .auth-signup-form(v-if='!allow')
    h2.title(v-t="'auth_form.invitation_required'")
  .auth-signup-form(v-if='allow')
    .auth-signup-form__welcome
      h2.title(v-t="{ path: 'auth_form.welcome', args: { siteName: vars.site_name } }")
      p(v-t="'auth_form.sign_up_helptext'")
    .auth-signup-form__name
      //- label(v-t="'auth_form.name'")
      v-text-field(type='text' autofocus :placeholder="$t('auth_form.name_placeholder')" v-model='vars.name' required='true')
    .auth-signup-form__consent(v-if='termsUrl')
      v-checkbox.auth-signup-form__legal-accepted(v-model='vars.legalAccepted')
        template(v-slot:label)
          span(v-html="$t('auth_form.i_accept', { termsUrl: termsUrl, privacyUrl: privacyUrl })")
      validation-errors(:subject='user', field='legalAccepted')
    v-card-actions
      v-btn(text color="warning" v-t="'common.action.back'" @click='user.emailStatus = null')
      v-spacer
      v-btn.auth-signup-form__submit(color="primary" :disabled='!vars.name || (termsUrl && !vars.legalAccepted)' v-t="'auth_form.create_account'" @click='submit()')
    v-recaptcha(v-if='useRecaptcha' ref="invisibleRecaptcha" :sitekey="recaptchaKey" :loadRecaptchaScript="true" size="invisible" @verify="submitForm")
</template>
