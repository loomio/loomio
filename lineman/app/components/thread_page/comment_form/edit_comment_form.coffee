angular.module('loomioApp').factory 'EditCommentForm', ->
  templateUrl: 'generated/components/thread_page/comment_form/edit_comment_form.html'
  controller: ($scope, comment, FlashService) ->
    $scope.comment = comment.clone()

    $scope.submit = ->
      $scope.processing = true
      $scope.comment.save().then ->
        $scope.processing = false
        FlashService.success 'comment_form.changes_saved'
        $scope.$close()
      , ->
        $scope.processing = false
        $rootScope.$broadcast 'pageError', 'cantEditComment'