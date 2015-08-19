angular.module('loomioApp').directive 'commentForm', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_form/comment_form.html'
  replace: true
  controller: ($scope, FlashService, Records, CurrentUser, KeyEventService) ->
    discussion = $scope.comment.discussion()
    group = $scope.comment.group()

    $scope.submit = ->
      $scope.isDisabled = true
      $scope.comment.save().then ->
        $scope.isDisabled = false
        $scope.comment = Records.comments.build(discussionId: discussion.id)
        FlashService.success('comment_form.messages.created')
      , ->
        $scope.isDisabled = false

    $scope.$on 'replyToCommentClicked', (event, parentComment) ->
      $scope.comment.parentId = parentComment.id

    $scope.removeAttachment = (attachment) ->
      ids = $scope.comment.newAttachmentIds
      ids.splice ids.indexOf(attachment.id), 1
      Records.attachments.destroy(attachment.id)

    $scope.updateMentionables = (fragment) ->
      regex = new RegExp(fragment, 'i')
      $scope.mentionables = _.filter group.members(), (member) ->
        return false if member.id == CurrentUser.id
        (member.name.test(regex) or member.username.test(regex))

    $scope.fetchByNameFragment = (fragment) ->
      $scope.updateMentionables(fragment)
      Records.memberships.fetchByNameFragment(fragment, group.key).then ->
        $scope.updateMentionables(fragment)

    KeyEventService.submitOnEnter $scope
