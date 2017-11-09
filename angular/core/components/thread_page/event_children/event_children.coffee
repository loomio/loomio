angular.module('loomioApp').directive 'eventChildren', (NestedEventWindow) ->
  scope: {discussion: '=', parentEvent: '=', settings: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/event_children/event_children.html'
  replace: true
  controller: ($scope) ->
    $scope.eventWindow = new NestedEventWindow(discussion: $scope.discussion, parentEvent: $scope.parentEvent, settings: $scope.settings)
    $scope.$on 'showReplyForm', (e, parentComment) ->
      $scope.eventWindow.showMore = true
