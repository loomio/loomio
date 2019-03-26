{ listenForLoading }    = require 'shared/helpers/listen'
{ getProviderIdentity } = require 'shared/helpers/user'
AppConfig               = require 'shared/services/app_config'


angular.module('loomioApp').directive 'authForm', ->
  scope: {preventClose: '=', user: '='}
  templateUrl: 'generated/components/auth/form/auth_form.html'
  controller: ['$scope', ($scope) ->
    $scope.emailLogin = AppConfig.features.app.email_login
    $scope.siteName = AppConfig.theme.site_name
    $scope.privacyUrl = AppConfig.theme.privacy_url

    $scope.loginComplete = ->
      $scope.user.sentLoginLink or $scope.user.sentPasswordLink

    $scope.pendingProviderIdentity = getProviderIdentity()

    listenForLoading $scope
  ]
