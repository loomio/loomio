angular.module('loomioApp').controller 'CommentFormController', ($scope, FlashService, Records, CurrentUser) ->
  $scope.comment = $scope.comment or Records.comments.initialize(discussion_id: $scope.discussion.id)
  group = $scope.discussion.group()

  $scope.submit = ->
    $scope.comment.save().then ->
      $scope.comment = Records.comments.initialize(discussion_id: $scope.discussion.id)
      $scope.$emit('commentSaveSuccess')
      FlashService.success('comment_form.flash_messages.created')

  $scope.$on 'replyToCommentClicked', (event, parentComment) ->
    $scope.comment.parentId = parentComment.id

  $scope.removeAttachment = (attachment) ->
    ids = $scope.comment.newAttachmentIds
    ids.splice ids.indexOf(attachment.id), 1
    Records.attachments.destroy(attachment.id)

  $scope.updateMentionables = (fragment) ->
    allMentionables = _.filter group.members(), (member) ->
      member.id != CurrentUser.id and \
      (~member.name.search(new RegExp(fragment, 'i')) or \
       ~member.label.search(new RegExp(fragment, 'i')))
    $scope.mentionables = _.take allMentionables, 5 # filters are being annoying

  $scope.fetchByNameFragment = (fragment) ->
    $scope.updateMentionables(fragment)
    Records.memberships.fetchByNameFragment(fragment, group.key).then -> $scope.updateMentionables(fragment)
  $scope.fetchByNameFragment('')
