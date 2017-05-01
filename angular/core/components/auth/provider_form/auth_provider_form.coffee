angular.module('loomioApp').directive 'authProviderForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/provider_form/auth_provider_form.html'
  controller: ($scope, $window, AppConfig) ->
    $scope.providers = AppConfig.identityProviders.concat([{name: 'email', icon: 'envelope-o'}])

    $scope.select = (provider) ->
      if provider.href
        $window.location = provider.href
      else
        $scope.user.provider = provider.name
