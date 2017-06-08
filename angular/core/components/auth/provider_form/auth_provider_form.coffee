angular.module('loomioApp').directive 'authProviderForm', ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/provider_form/auth_provider_form.html'
  controller: ($scope, $window, AppConfig) ->
    $scope.providers = AppConfig.identityProviders

    $scope.select = (provider) ->
      $scope.$emit 'processing'
      $window.location = "#{provider.href}?back_to=#{$window.location.href}"
