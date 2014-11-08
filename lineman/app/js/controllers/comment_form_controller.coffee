angular.module('loomioApp').controller 'CommentFormController', ($scope, CommentModel, CommentService, UserAuthService) ->

  discussion = $scope.comment.discussion()
  # $scope.comment is passed in via attribute
  saveSuccess = ->
    $scope.comment = new CommentModel(discussion_id: discussion.id)
    $scope.$emit('commentSaveSuccess')

  saveError = (error) ->
    # set ngMessages
    console.log error

  $scope.submit = ->
    CommentService.save($scope.comment, saveSuccess, saveError)


