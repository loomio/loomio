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
  .md-block.auth-email-form__email
    label(translate='auth_form.email')
    v-text-field#email.lmo-primary-form-input(name='email', type='email', :placeholder="$t('auth_form.email_placeholder')" v-model='email')
    //- validation_errors(subject='user', field='email')
  v-btn.md-primary.md-raised.auth-email-form__submit(@click='submit()', :disabled='!email', v-t="'auth_form.continue_with_email'")
</template>
<style lang="scss">
</style>


<!-- AppConfig   = require 'shared/services/app_config'
AuthService = require 'shared/services/auth_service'
EventBus    = require 'shared/services/event_bus'
I18n        = require 'shared/services/i18n'

{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'authEmailForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/email_form/auth_email_form.html'
  controller: ['$scope', ($scope) ->
    $scope.email = $scope.user.email

    $scope.submit = ->
      return unless $scope.validateEmail()
      EventBus.emit $scope, 'processing'
      $scope.user.email = $scope.email
      AuthService.emailStatus($scope.user).finally -> EventBus.emit $scope, 'doneProcessing'

    $scope.validateEmail = ->
      $scope.user.errors = {}
      if !$scope.email
        $scope.user.errors.email = [I18n.t('auth_form.email_not_present')]
      else if !$scope.email.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)
        $scope.user.errors.email = [I18n.t('auth_form.invalid_email')]
      !$scope.user.errors.email?

    submitOnEnter($scope, anyEnter: true)
    EventBus.emit $scope, 'focus'
  ] -->
