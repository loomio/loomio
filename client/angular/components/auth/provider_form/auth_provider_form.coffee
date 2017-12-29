AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').directive 'authProviderForm', ['$window', ($window) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/provider_form/auth_provider_form.html'
  controller: ['$scope', ($scope) ->
    $scope.providers = AppConfig.identityProviders

    $scope.select = (provider) ->
      $scope.$emit 'processing'
      $window.location = "#{provider.href}?back_to=#{$window.location.href}"
  ]
]
