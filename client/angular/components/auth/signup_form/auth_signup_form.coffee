AppConfig   = require 'shared/services/app_config.coffee'
EventBus    = require 'shared/services/event_bus.coffee'
AuthService = require 'shared/services/auth_service.coffee'
I18n        = require 'shared/services/i18n.coffee'

{ submitOnEnter } = require 'shared/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'authSignupForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signup_form/auth_signup_form.html'
  controller: ['$scope', ($scope) ->
    $scope.recaptchaKey = AppConfig.recaptchaKey
    $scope.name         = $scope.user.name
    $scope.vars         = {name: $scope.name}
    $scope.allow        = ->
      AppConfig.features.app.create_user or AppConfig.pendingIdentity.identity_type?

    $scope.submit = ->
      if $scope.vars.name
        $scope.user.errors = {}
        EventBus.emit $scope, 'processing'
        $scope.user.name  = $scope.vars.name
        AuthService.signUp($scope.user).finally -> EventBus.emit $scope, 'doneProcessing'
      else
        $scope.user.errors =
          name: [I18n.t('auth_form.name_required')]

    submitOnEnter($scope, anyEnter: true)
    EventBus.emit $scope, 'focus'
  ]
