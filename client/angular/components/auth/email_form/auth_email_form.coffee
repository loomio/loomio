AppConfig   = require 'shared/services/app_config'
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
  ]
