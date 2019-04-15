<script lang="coffee">
export default
  props:
  data: ->
  methods:
</script>
<template lang="pug">
.auth-email-form
  md-input-container.md-block.auth-email-form__email
    label(translate='auth_form.email')
    input#email.lmo-primary-form-input(name='email', type='email', placeholder="{{ \'auth_form.email_placeholder\' | translate}}", ng-model='email')
    validation_errors(subject='user', field='email')
  md-button.md-primary.md-raised.auth-email-form__submit(ng-click='submit()', ng-disabled='!email', translate='auth_form.continue_with_email', aria-label="{{ \'auth_form.continue_with_email\' | translate }}")
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
