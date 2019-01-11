EventBus     = require 'shared/services/event_bus'
FlashService = require 'shared/services/flash_service'

angular.module('loomioApp').factory 'RevokeAppForm', ['$rootScope', ($rootScope) ->
  template: require('./revoke_app_form.haml')
  controller: ['$scope', 'application', ($scope, application) ->
    $scope.application = application

    $scope.submit = ->
      $scope.application.revokeAccess().then ->
        FlashService.success 'revoke_app_form.messages.success', name: $scope.application.name
        $scope.$close()
      , ->
        EventBus.broadcast $rootScope, 'pageError', 'cantRevokeApplication', $scope.application
        $scope.$close()
  ]
]
