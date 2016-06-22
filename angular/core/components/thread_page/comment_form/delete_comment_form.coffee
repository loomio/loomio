angular.module('loomioApp').factory 'DeleteCommentForm', ->
  templateUrl: 'generated/components/thread_page/comment_form/delete_comment_form.html'
  controller: ($scope, $rootScope, Records, comment) ->
    $scope.comment = comment

    $scope.submit = ->
      $scope.comment.destroy().then ->
        $scope.$close()
        _.find($scope.comment.discussion().events(), (event) ->
          event.kind == 'new_comment' and
          event.eventable.id == $scope.comment.id
        ).delete()
      , ->
        $rootScope.$broadcast 'pageError', 'cantDeleteComment'
