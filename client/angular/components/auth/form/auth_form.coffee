AppConfig = require 'shared/services/app_config.coffee'

{ listenForLoading } = require 'shared/helpers/listen.coffee'

angular.module('loomioApp').directive 'authForm', ->
  scope: {preventClose: '=', user: '='}
  templateUrl: 'generated/components/auth/form/auth_form.html'
  controller: ['$scope', ($scope) ->
    $scope.loginComplete = ->
      $scope.user.sentLoginLink or $scope.user.sentPasswordLink

    if _.contains(_.pluck(AppConfig.identityProviders, 'name'), (AppConfig.pendingIdentity or {}).identity_type)
      $scope.pendingProviderIdentity = AppConfig.pendingIdentity

    listenForLoading $scope
  ]
