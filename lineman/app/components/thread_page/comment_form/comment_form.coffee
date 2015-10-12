angular.module('loomioApp').directive 'commentForm', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_form/comment_form.html'
  replace: true
  controller: ($scope, $rootScope, FlashService, Records, CurrentUser, KeyEventService, AbilityService, ScrollService) ->
    discussion = $scope.comment.discussion()
    group = $scope.comment.group()

    $scope.formInFocus = ->   $rootScope.$broadcast 'hideFeedbackForm'
    $scope.formLostFocus = -> $rootScope.$broadcast 'showFeedbackForm'

    $scope.showCommentForm = ->
      AbilityService.canAddComment(discussion)

    $scope.threadIsPublic = ->
      discussion.private == false

    $scope.threadIsPrivate = ->
      discussion.private == true

    $scope.submit = ->
      $scope.isDisabled = true
      $scope.comment.save().then ->
        $scope.isDisabled = false
        if $scope.comment.isReply()
          FlashService.success('comment_form.messages.replied', name: $scope.comment.parent().authorName())
        else
          FlashService.success('comment_form.messages.created')
        $scope.comment = Records.comments.build(discussionId: discussion.id)
      , ->
        $scope.isDisabled = false

    $scope.$on 'replyToCommentClicked', (event, parentComment) ->
      $scope.comment.parentId = parentComment.id
      ScrollService.scrollTo('.comment-form__comment-field')

    $scope.removeAttachment = (attachment) ->
      ids = $scope.comment.newAttachmentIds
      ids.splice ids.indexOf(attachment.id), 1
      Records.attachments.destroy(attachment.id)

    $scope.updateMentionables = (fragment) ->
      regex = new RegExp("(^#{fragment}| +#{fragment})", 'i')
      allMembers = _.filter group.members(), (member) ->
        return false if member.id == CurrentUser.id
        (regex.test(member.name) or regex.test(member.username))
      $scope.mentionables = allMembers.slice(0, 5)

    $scope.fetchByNameFragment = (fragment) ->
      $scope.updateMentionables(fragment)
      Records.memberships.fetchByNameFragment(fragment, group.key).then ->
        $scope.updateMentionables(fragment)

    KeyEventService.submitOnEnter $scope
