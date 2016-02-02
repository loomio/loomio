angular.module('loomioApp').factory 'DeleteCommentForm', ->
  templateUrl: 'generated/components/thread_page/comment_form/delete_comment_form.html'
  controller: ($scope, $rootScope, Records, comment) ->
    $scope.comment = comment

    $scope.submit = ->
      $scope.comment.destroy().then ->
        $scope.$close()
        Records.events.find(commentId: $scope.comment.id)[0].delete()
      , ->
        $rootScope.$broadcast 'pageError', 'cantDeleteComment'
