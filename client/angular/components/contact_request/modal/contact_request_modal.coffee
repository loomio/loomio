EventBus = require 'shared/services/event_bus'

angular.module('loomioApp').factory 'ContactRequestModal', ->
  template: require('./contact_request_modal.haml')
  controller: ['$scope', 'user', ($scope, user) ->
    $scope.user = user
    EventBus.listen $scope, '$close', $scope.$close
  ]
