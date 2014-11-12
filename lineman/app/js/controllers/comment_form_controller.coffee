angular.module('loomioApp').controller 'CommentFormController', ($scope, CommentModel, CommentService, MembershipService, RecordStoreService) ->
  discussion = $scope.comment.discussion()
  group = discussion.group()
  $scope.mentionables = group.members()

  $scope.getMentionables = (fragment) ->
    MembershipService.fetchByNameFragment fragment, group.id, ->
      $scope.mentionables = _.filter(group.members(), (member) ->
        ~member.name.toLowerCase().indexOf(fragment.toLowerCase()) or \
        ~member.label.toLowerCase().indexOf(fragment.toLowerCase()))

  saveSuccess = ->
    $scope.comment = new CommentModel(discussion_id: discussion.id)
    $scope.$emit('commentSaveSuccess')

  saveError = (error) ->
    console.log error

  $scope.submit = ->
    console.log $scope.comment
    CommentService.save($scope.comment, saveSuccess, saveError)


