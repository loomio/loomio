angular.module('loomioApp').controller 'CommentFormController', ($scope, CommentModel, CommentService, UserAuthService) ->

  # $scope.comment is passed in via attribute
  saveSuccess = ->
    $scope.comment = new CommentModel(discussion_id: $scope.discussion.id)
    $scope.isExpanded = false

  saveError = (error) ->
    # set ngMessages
    console.log error

  $scope.submit = ->
    CommentService.save($scope.comment, saveSuccess, saveError)


