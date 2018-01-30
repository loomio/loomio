AppConfig         = require 'shared/services/app_config.coffee'
EventBus          = require 'shared/services/event_bus.coffee'
NestedEventWindow = require 'shared/services/nested_event_window.coffee'

angular.module('loomioApp').directive 'eventChildren', ->
  scope: {parentEvent: '=', parentEventWindow: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/event_children/event_children.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.debug = -> AppConfig.debug
    $scope.eventWindow = new NestedEventWindow
      parentEvent:       $scope.parentEvent
      discussion:        $scope.parentEventWindow.discussion
      initialSequenceId: $scope.parentEventWindow.initialSequenceId
      per:               $scope.parentEventWindow.per

    EventBus.listen $scope, 'replyToEvent', (e, event) ->
      if event.id == $scope.parentEvent.id
        $scope.eventWindow.max = false
  ]
