{ scrollTo } = require 'shared/helpers/window.coffee'

angular.module('loomioApp').directive 'threadLintel', ->
  restrict: 'E'
  templateUrl: 'generated/components/thread_lintel/thread_lintel.html'
  replace: true
  controller: ($scope) ->
    $scope.show = ->
      $scope.showLintel && $scope.discussion

    $scope.scrollToThread = ->
      scrollTo 'h1'

    $scope.$on 'currentComponent', (event, options) ->
      $scope.currentComponent = options['page']
      $scope.discussion = options.discussion

    $scope.$on 'showThreadLintel', (event, bool) ->
      $scope.showLintel = bool

    $scope.$on 'threadPosition', (event, discussion, position) ->
      $scope.position = position
      $scope.discussion = discussion
      $scope.positionPercent = (position / discussion.lastSequenceId) *100
