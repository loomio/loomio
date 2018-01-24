angular.module('loomioApp').factory 'DeleteCommentForm', ->
  templateUrl: 'generated/components/thread_page/comment_form/delete_comment_form.html'
  controller: ($scope, $rootScope, Records, comment) ->
    $scope.comment = comment

    $scope.submit = ->
      $scope.comment.destroy().then ->
        $scope.$close()
      , ->
        $rootScope.$broadcast 'pageError', 'cantDeleteComment'
