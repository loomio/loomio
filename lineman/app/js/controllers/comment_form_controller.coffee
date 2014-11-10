angular.module('loomioApp').controller 'CommentFormController', ($scope, CommentModel, CommentService, MembershipService, RecordStoreService) ->
  $scope.mentionables = $scope.group.members()
  discussion = $scope.comment.discussion()
  group = discussion.group()

  $scope.getMentionables = (fragment) ->
    MembershipService.fetchByNameFragment fragment, group.id, ->
      $scope.mentionables = group.members()

  saveSuccess = ->
    $scope.comment = new CommentModel(discussion_id: discussion.id)
    $scope.$emit('commentSaveSuccess')

  saveError = (error) ->
    console.log error

  $scope.submit = ->
    CommentService.create($scope.comment, saveSuccess, saveError)


