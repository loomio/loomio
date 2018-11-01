angular.module('loomioApp').directive 'truncateComment', ->
  scope: {comment: '='}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/truncate_comment/truncate_comment.html'
  controller: ['$scope', '$timeout', ($scope, $timeout) ->
    commentHeight = 0
    LONG_COMMENT_HEIGHT = 300

    $scope.toggleComment = ->
      angular.element($scope.commentElement()).toggleClass('new-comment__truncated')
      $scope.commentCollapsed = !$scope.commentCollapsed

    $scope.commentIsLong = ->
      commentHeight > LONG_COMMENT_HEIGHT

    $scope.commentElement = ->
      document.querySelector("#comment-#{$scope.comment.id} .new-comment__body")

    $scope.elementContainsImage = ->
      $scope.commentElement().getElementsByTagName('img').length > 0

    $timeout ->
      commentHeight = $scope.commentElement().clientHeight
      $scope.toggleComment() if $scope.commentIsLong()
    return
  ]
