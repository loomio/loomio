angular.module('loomioApp').directive 'authProviderForm', ->
  templateUrl: 'generated/components/auth/provider_form/auth_provider_form.html'
  controller: ($scope, $window, AppConfig) ->
    $scope.expanded = AppConfig.oauthProviders.length <= 3
    $scope.providers = _.take AppConfig.oauthProviders, 3
    $scope.expand = ->
      $scope.expanded = true
      $scope.providers = AppConfig.oauthProviders

    $scope.select = (provider) -> $window.location = provider.href
