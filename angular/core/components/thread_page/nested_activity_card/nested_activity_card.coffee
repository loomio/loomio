angular.module('loomioApp').directive 'nestedActivityCard', (ThreadWindow)->
  scope: {discussion: '=', loading: '=', activeCommentId: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/nested_activity_card/nested_activity_card.html'
  replace: true
  controller: ($scope) ->
    $scope.tw = new ThreadWindow(discussion: $scope.discussion)
    return
