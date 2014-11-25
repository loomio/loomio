angular.module('loomioApp').controller 'CommentFormController', ($scope, CommentModel, CommentService, MembershipService) ->
  discussion = $scope.comment.discussion()
  group = discussion.group()
  $scope.mentionables = group.members()

  $scope.getMentionables = (fragment) ->
    MembershipService.fetchByNameFragment fragment, group.id, ->
      $scope.mentionables = _.filter(group.members(), (member) ->
        ~member.name.search(new RegExp(fragment, 'i')) or \
        ~member.label.search(new RegExp(fragment, 'i')))

  saveSuccess = ->
    $scope.comment = new CommentModel(discussion_id: discussion.id)
    $scope.$emit('commentSaveSuccess')

  saveError = (error) ->
    console.log error

  $scope.submit = ->
    CommentService.save($scope.comment, saveSuccess, saveError)


