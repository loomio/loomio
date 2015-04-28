angular.module('loomioApp').controller 'CommentFormController', ($scope, FlashService, Records) ->
  $scope.comment = $scope.comment or Records.comments.initialize(discussion_id: $scope.discussion.id)
  group = $scope.discussion.group()
  $scope.mentionables = group.members()

  $scope.fetchByNameFragment = (fragment) ->
    Records.memberships.fetchByNameFragment(fragment, $scope.discussion.group().key).then ->
      $scope.mentionables = group.members()

  saveSuccess = ->
    $scope.comment = Records.comments.initialize(discussion_id: $scope.discussion.id)
    $scope.$emit('commentSaveSuccess')
    FlashService.success('comment_form.flash_messages.created')

  saveError = (error) ->
    console.log error

  $scope.submit = ->
    $scope.comment.save().then(saveSuccess, saveError)

  $scope.$on 'replyToCommentClicked', (event, parentComment) ->
    $scope.comment.parentId = parentComment.id

  $scope.removeAttachment = (attachment) ->
    ids = $scope.comment.newAttachmentIds
    ids.splice ids.indexOf(attachment.id), 1
    Records.attachments.destroy(attachment.id)
