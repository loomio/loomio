angular.module('loomioApp').directive 'threadLintel', ->
  restrict: 'E'
  templateUrl: 'generated/components/thread_lintel/thread_lintel.html'
  replace: true
  controller: ($scope) ->
    $scope.show = false

    # can probably delete this
    $scope.$on 'currentComponent', (event, componentName) ->
      $scope.show = componentName == 'threadPage'

    $scope.$on 'viewingThread', (event, discussion) ->
      $scope.discussion = discussion

    $scope.$on 'showThreadLintel', (event, bool) ->
      #console.log 'bool', bool
      $scope.show = bool

    $scope.$on 'threadPosition', (event, discussion, position) ->
      #console.log 'got thread position, total:', position, discussion.itemsCount
      $scope.position = position
      $scope.discussion = discussion
      #console.log position, discussion.lastSequenceId
      $scope.positionPercent = (position / discussion.lastSequenceId) *100

