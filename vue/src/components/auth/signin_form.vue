<script lang="coffee">
import AuthService  from '@/shared/services/auth_service'
import { hardReload } from '@/shared/helpers/window'
import Session from '@/shared/services/session'
import AuthModalMixin from '@/mixins/auth_modal'
import AppConfig from '@/shared/services/app_config'
import Flash from '@/shared/services/flash'
import EventBus from '@/shared/services/event_bus'

export default
  mixins: [AuthModalMixin]
  props:
    user: Object

  data: ->
    siteName: AppConfig.theme.site_name
    vars: {}
    loading: false

  methods:
    signIn: ->
      @user.name = @vars.name if @vars.name?
      @loading = true
      AuthService.signIn(@user).finally =>
        @loading = false

    signInAndSetPassword: ->
      @loading = true
      @signIn().then =>
        @loading = false
        EventBus.$emit 'openModal',
          component: 'ChangePasswordForm'
          props:
            user: Session.user()

    sendLoginLink: ->
      @loading = true
      AuthService.sendLoginLink(@user).finally =>
        @loading = false

    submit: ->
      if @user.hasPassword or @user.hasToken
        @signIn()
      else
        @sendLoginLink()
</script>
<template lang="pug">
v-card.auth-signin-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" @keydown.enter="submit()")
  v-card-title
    h1.headline(tabindex="-1" role="status" aria-live="assertive" v-t="{ path: 'auth_form.welcome_back', args: { name: user.name } }")
    v-spacer
    v-btn.back-button(icon :title="$t('common.action.back')" @click='user.authForm = null')
      v-icon mdi-close

  v-sheet.mx-4.pb-4
    submit-overlay(:value='loading')
    v-layout(justify-center)
      auth-avatar(:user='user')
    .auth-signin-form__token.text-center(v-if='user.hasToken')
      validation-errors(:subject='user', field='token')
      v-btn.my-4.auth-signin-form__submit(color="primary" @click='submit()' v-if='!user.errors.token' :loading="loading")
        span(v-t="{ path: 'auth_form.sign_in_as', args: {name: user.name}}")
      v-btn.my-4.auth-signin-form__submit(color="primary" @click='sendLoginLink()' v-if='user.errors.token' :loading="loading")
        span(v-t="'auth_form.login_link'")
      p
        span(v-t="'auth_form.set_password_helptext'").mr-1
        a.lmo-pointer(@click='signInAndSetPassword()' v-t="'auth_form.set_password'")
    .auth-signin-form__no-token(v-if='!user.hasToken')
      .auth-signin-form__password(v-if='user.hasPassword')
        p.text-center.my-2(v-t="'auth_form.enter_your_password'")
        v-text-field#password(:label="$t('auth_form.password')" name='password' type='password' outlined autofocus required v-model='user.password' autocomplete="current-password")
        validation-errors(:subject='user', field='password')

        v-card-actions
          v-btn.auth-signin-form__login-link(:color="user.hasPassword ? '' : 'primary'" v-t="user.hasPassword ? 'auth_form.forgot_password' : 'auth_form.login_link'" @click='sendLoginLink()' :loading="!user.password && loading")
          v-spacer
          v-btn.auth-signin-form__submit(:color="user.hasPassword ? 'primary' : ''" v-t="'auth_form.sign_in'" @click='submit()' :disabled='!user.password' v-if='user.hasPassword' :loading="user.password && loading")

      .auth-signin-form__no-password(v-if='!user.hasPassword')
        v-card-actions.justify-space-around
          v-btn.auth-signin-form__submit(color="primary" @click='sendLoginLink()' v-t="'auth_form.sign_in_via_email'" :loading="loading")
</template>

<style lang="sass">
.auth-signin-form__no-password .auth-signin-form__submit
  display: block

</style>
