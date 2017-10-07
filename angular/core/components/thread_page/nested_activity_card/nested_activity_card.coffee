angular.module('loomioApp').directive 'nestedActivityCard', (ThreadRenderer)->
  scope: {discussion: '=', loading: '=', activeCommentId: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/nested_activity_card/nested_activity_card.html'
  replace: true
  controller: ($scope) ->
    $scope.r = new ThreadRenderer
      scope: $scope
      per: 10
      discussion: $scope.discussion

    return
