angular.module('loomioApp').directive 'authProviderForm', ->
  templateUrl: 'generated/components/auth/provider_form/auth_provider_form.html'
  controller: ($scope, $window, AppConfig) ->
    $scope.expanded = AppConfig.identityProviders.length <= 3
    $scope.providers = _.take AppConfig.identityProviders, 3
    $scope.expand = ->
      $scope.expanded = true
      $scope.providers = AppConfig.identityProviders

    $scope.select = (provider) -> $window.location = provider.href
