AppConfig = require 'shared/services/app_config'
EventBus  = require 'shared/services/event_bus'

angular.module('loomioApp').directive 'authProviderForm', ['$window', ($window) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/provider_form/auth_provider_form.html'
  controller: ['$scope', ($scope) ->
    $scope.providers = AppConfig.identityProviders
    $scope.capitalize = _.capitalize

    $scope.select = (provider) ->
      EventBus.emit $scope, 'processing'
      $window.location = "#{provider.href}?back_to=#{$window.location.href}"
  ]
]
