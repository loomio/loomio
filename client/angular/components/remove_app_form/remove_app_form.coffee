EventBus     = require 'shared/services/event_bus'
FlashService = require 'shared/services/flash_service'

angular.module('loomioApp').factory 'RemoveAppForm', ['$rootScope', ($rootScope) ->
  template: require('./remove_app_form.haml')
  controller: ['$scope', 'applcation', ($scope, application) ->
    $scope.application = application

    $scope.submit = ->
      $scope.application.destroy().then ->
        FlashService.success 'remove_app_form.messages.success', name: $scope.application.name
        $scope.$close()
      , ->
        EventBus.broadcast $rootScope, 'pageError', 'cantDestroyApplication', $scope.application
        $scope.$close()
  ]
]
