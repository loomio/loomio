angular.module('loomioApp').directive 'eventChildren', (StrandWindow) ->
  scope: {parent: '=', threadWindow: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/event_children/event_children.html'
  replace: true
  controller: ($scope) ->
    $scope.sw = new StrandWindow(parentEvent: $scope.parent, threadWindow: $scope.threadWindow)
    $scope.$on 'showReplyForm', (e, parentComment) ->
      $scope.sw.showMore = true
