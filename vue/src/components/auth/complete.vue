<script lang="coffee">
import Records       from '@/shared/services/records'
import { submitForm }    from '@/shared/helpers/form'
export default
  props:
    user: Object
  data: ->
    session: Records.sessions.build(email: @user.email)
    attempts: 0
  methods:
    submit: -> submitForm @, @session,
      successCallback: -> hardReload()
      failureCallback: ->
        @attempts += 1
        # EventBus.emit $scope, 'doneProcessing'
      skipDoneProcessing: true
</script>
<template lang="pug">
.auth-complete
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
    .auth-complete__code.md-no-errors
      v-text-field.lmo-primary-form-input(type='integer', maxlength='6', v-model='session.code')
    //- validation_errors(subject='session', field='password')
    br
    span(v-t="'auth_form.check_spam_folder'")
    .lmo-md-action
      v-btn.md-raised.md-primary(@click='submit()', :disabled='!session.code', v-t="'auth_form.sign_in'")
</template>
<style lang="scss">
</style>
