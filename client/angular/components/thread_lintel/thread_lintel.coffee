EventBus = require 'shared/services/event_bus.coffee'

{ scrollTo } = require 'shared/helpers/window.coffee'

angular.module('loomioApp').directive 'threadLintel', ->
  restrict: 'E'
  templateUrl: 'generated/components/thread_lintel/thread_lintel.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.show = ->
      $scope.showLintel && $scope.discussion

    $scope.scrollToThread = ->
      scrollTo 'h1'

    EventBus.listen $scope, 'currentComponent', (event, options) ->
      $scope.currentComponent = options['page']
      $scope.discussion = options.discussion

    EventBus.listen $scope, 'showThreadLintel', (event, bool) ->
      $scope.showLintel = bool

    EventBus.listen $scope, 'threadPosition', (event, discussion, position) ->
      $scope.position = position
      $scope.discussion = discussion
      $scope.positionPercent = (position / discussion.lastSequenceId) *100
  ]
