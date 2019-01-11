AppConfig         = require 'shared/services/app_config'
EventBus          = require 'shared/services/event_bus'
NestedEventWindow = require 'shared/services/nested_event_window'

angular.module('loomioApp').directive 'eventChildren', ->
  scope: {parentEvent: '=', parentEventWindow: '='}
  restrict: 'E'
  template: require('./event_children.haml')
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.debug = -> AppConfig.debug
    $scope.eventWindow = new NestedEventWindow
      parentEvent:       $scope.parentEvent
      discussion:        $scope.parentEventWindow.discussion
      initialSequenceId: $scope.parentEventWindow.initialSequenceId
      per:               $scope.parentEventWindow.per

    EventBus.listen $scope, 'replyToEvent', (e, event, comment) ->
      if event.id == $scope.parentEvent.id
        $scope.eventWindow.max = false
  ]
