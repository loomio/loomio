angular.module('loomioApp').directive 'authProviderForm', ->
  scope: {session: '='}
  templateUrl: 'generated/components/auth/provider_form/auth_provider_form.html'
  controller: ($scope, $window, AppConfig) ->
    $scope.providers = AppConfig.oauthProviders
    $scope.select = (provider) -> $window.location = provider.href
