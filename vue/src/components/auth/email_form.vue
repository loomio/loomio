<script lang="coffee">
import AuthService from '@/shared/services/auth_service'
import EventBus    from '@/shared/services/event_bus'

export default
  props:
    user: Object
  data: ->
    email: @user.email
  watch:
    # GK: NB: not sure why this hack is necessary, but email is not set otherwise
    'user.email': ->
      @email = @user.email
  methods:
    submit: ->
      return unless @validateEmail()
      # EventBus.emit $scope, 'processing'
      @user.email = @email
      AuthService.emailStatus(@user).finally =>
        console.log 'doneProcessing'
        # EventBus.emit $scope, 'doneProcessing'
    validateEmail: ->
      @user.errors = {}
      if !@email
        @user.errors.email = [@$t('auth_form.email_not_present')]
      else if !@email.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)
        @user.errors.email = [@$t('auth_form.invalid_email')]
      !@user.errors.email?
</script>
<template lang="pug">
.auth-email-form
  .auth-email-form__email
    label(translate='auth_form.email')
    v-text-field#email.lmo-primary-form-input(name='email' type='email' :placeholder="$t('auth_form.email_placeholder')" v-model='email')
    validation_errors(:subject='user' field='email')
  v-card-actions
    v-spacer
    v-btn.auth-email-form__submit(color="primary" @click='submit()' :disabled='!email' v-t="'auth_form.continue_with_email'")
</template>
