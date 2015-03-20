angular.module('loomioApp').controller 'CommentFormController', ($scope, Records) ->
  $scope.comment = $scope.comment or Records.comments.initialize(discussion_id: $scope.discussion.id)
  group = $scope.discussion.group()

  $scope.getMentionables = (fragment) ->
    Records.memberships.fetchByNameFragment(fragment, group.key).then ->
      $scope.mentionables = _.filter(group.members(), (member) ->
        ~member.name.search(new RegExp(fragment, 'i')) or \
        ~member.label.search(new RegExp(fragment, 'i')))

  saveSuccess = ->
    $scope.comment = Records.comments.initialize(discussion_id: $scope.discussion.id)
    $scope.$emit('commentSaveSuccess')

  saveError = (error) ->
    console.log error

  $scope.submit = ->
    $scope.comment.save().then(saveSuccess, saveError)

  $scope.$on 'showReplyToCommentForm', (event, parentComment) ->
    $scope.comment.parentId = parentComment.id

  $scope.removeAttachment = (attachment) ->
    ids = $scope.comment.newAttachmentIds
    ids.splice ids.indexOf(attachment.id), 1
    Records.attachments.destroy(attachment.id)
