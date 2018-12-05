AppConfig = require 'shared/services/app_config'
EventBus  = require 'shared/services/event_bus'

angular.module('loomioApp').directive 'authProviderForm', ['$window', ($window) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/provider_form/auth_provider_form.html'
  controller: ['$scope', ($scope) ->
    $scope.emailLogin = AppConfig.features.app.email_login
    $scope.providers = _.reject AppConfig.identityProviders, (provider) -> provider.name == 'slack'
    console.log $scope.providers
    $scope.capitalize = _.capitalize

    $scope.select = (provider) ->
      EventBus.emit $scope, 'processing'
      $window.location = "#{provider.href}?back_to=#{$window.location.href}"
  ]
]
