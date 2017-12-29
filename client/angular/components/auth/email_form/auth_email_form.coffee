AppConfig   = require 'shared/services/app_config.coffee'
AuthService = require 'shared/services/auth_service.coffee'
I18n        = require 'shared/services/i18n.coffee'

{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'authEmailForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/email_form/auth_email_form.html'
  controller: ['$scope', ($scope) ->
    $scope.email = $scope.user.email

    $scope.submit = ->
      return unless $scope.validateEmail()
      $scope.$emit 'processing'
      $scope.user.email = $scope.email
      AuthService.emailStatus($scope.user).finally -> $scope.$emit 'doneProcessing'

    $scope.validateEmail = ->
      $scope.user.errors = {}
      if !$scope.email
        $scope.user.errors.email = [I18n.t('auth_form.email_not_present')]
      else if !$scope.email.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)
        $scope.user.errors.email = [I18n.t('auth_form.invalid_email')]
      !$scope.user.errors.email?

    submitOnEnter($scope, anyEnter: true)
    $scope.$emit 'focus'
  ]
