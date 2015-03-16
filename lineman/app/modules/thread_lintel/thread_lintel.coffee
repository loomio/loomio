angular.module('loomioApp').directive 'threadLintel', ->
  restrict: 'E'
  templateUrl: 'generated/modules/thread_lintel/thread_lintel.html'
  replace: true
  controller: ($scope) ->
    $scope.show = false

    $scope.$on 'viewingThread', (event, discussion) ->
      $scope.discussion = discussion

    $scope.$on 'showThreadLintel', (event, bool) ->
      console.log 'bool', bool
      $scope.show = bool

    #$scope.$on 'threadPosition', (position) ->
      #$scope.position = position

