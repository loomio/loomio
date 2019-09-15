<script lang="coffee">
import Records       from '@/shared/services/records'
import { submitForm }    from '@/shared/helpers/form'
import Session from '@/shared/services/session'
import Flash from '@/shared/services/flash'
import AuthModalMixin from '@/mixins/auth_modal'
import openModal      from '@/shared/helpers/open_modal'
import AuthService from '@/shared/services/auth_service'

export default
  mixins: [AuthModalMixin]
  props:
    user: Object
  data: ->
    attempts: 0
  methods:
    submit: -> AuthService.signIn(@user, undefined, ( => @attempts += 1) )
</script>
<template lang="pug">
.auth-complete.text-center(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" @keydown.enter="submit()")
  auth-avatar(:user='user')
  h2.lmo-h2(v-t="'auth_form.check_your_email'")
  p(v-if='user.sentLoginLink')
    span(v-t="{ path: 'auth_form.login_link_sent', args: { email: user.email }}")
    br
    span(v-t="'auth_form.instructions'", v-if='attempts < 3')
  .lmo-validation-error(v-t="'auth_form.too_many_attempts'", v-if='attempts >= 3')
  p
  p.lmo-hint-text(v-if='user.sentPasswordLink', v-t="{ path: 'auth_form.password_link_sent', args: { email: user.email }}")
  .auth-complete__code-input(v-if='user.sentLoginLink && attempts < 3')
    .auth-complete__code.mx-auto(style="max-width: 256px")
      v-text-field.lmo-primary-form-input(outlined :placeholder="$t('auth_form.code')" type='integer' maxlength='6' v-model='user.code')
      //- validation-errors(:subject='session' field='password')
    span(v-t="'auth_form.check_spam_folder'")
  v-btn(color="primary" @click='submit()', :disabled='!user.code', v-t="'auth_form.sign_in'")
</template>
<style lang="sass">
.auth-complete__code input
  letter-spacing: 0.5em
  text-align: center
</style>
