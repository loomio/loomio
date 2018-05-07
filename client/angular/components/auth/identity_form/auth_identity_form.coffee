AppConfig   = require 'shared/services/app_config'
EventBus    = require 'shared/services/event_bus'
AuthService = require 'shared/services/auth_service'
I18n        = require 'shared/services/i18n'

{ hardReload }    = require 'shared/helpers/window'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'authIdentityForm', ->
  scope: {user: '=', identity: '='}
  templateUrl: 'generated/components/auth/identity_form/auth_identity_form.html'
  controller: ['$scope', ($scope) ->
    $scope.siteName = AppConfig.theme.site_name
    $scope.createAccount = ->
      EventBus.emit $scope, 'processing'
      AuthService.confirmOauth().then ->
        hardReload()
      , ->
        EventBus.emit $scope, 'doneProcessing'

    $scope.submit = ->
      EventBus.emit $scope, 'processing'
      $scope.user.email = $scope.email
      AuthService.sendLoginLink($scope.user).then (->), ->
        $scope.user.errors = {email: [I18n.t('auth_form.email_not_found')]}
      .finally ->
        EventBus.emit $scope, 'doneProcessing'

    submitOnEnter $scope, anyEnter: true
  ]
