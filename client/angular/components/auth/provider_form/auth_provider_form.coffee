AppConfig = require 'shared/services/app_config'
EventBus  = require 'shared/services/event_bus'

angular.module('loomioApp').directive 'authProviderForm', ['$window', ($window) ->
  scope: {user: '='}
  template: require('./auth_provider_form.haml')
  controller: ['$scope', ($scope) ->
    $scope.emailLogin = AppConfig.features.app.email_login
    $scope.providers = _.reject AppConfig.identityProviders, (provider) -> provider.name == 'slack'
    $scope.capitalize = _.capitalize

    $scope.select = (provider) ->
      EventBus.emit $scope, 'processing'
      $window.location = "#{provider.href}?back_to=#{$window.location.href}"
  ]
]
