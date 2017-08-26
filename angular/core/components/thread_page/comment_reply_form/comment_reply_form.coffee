angular.module('loomioApp').directive 'commentReplyForm', ($translate) ->
  scope: {parentComment: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_reply_form/comment_reply_form.html'
  replace: true
  controller: ($scope, $rootScope, FormService, Records, Session, KeyEventService, AbilityService, MentionService, AttachmentService, ScrollService, EmojiService, ModalService, AuthModal) ->

    $scope.commentHelptext = ->
      if $scope.parentComment.discussion().private
        $translate.instant 'comment_form.private_privacy_notice', groupName: $scope.comment.group().fullName
      else
        $translate.instant 'comment_form.public_privacy_notice'

    $scope.commentPlaceholder = ->
      if $scope.comment.parentId
        $translate.instant('comment_form.in_reply_to', name: $scope.comment.parent().authorName())
      else
        $translate.instant('comment_form.say_something')

    $scope.init = ->
      $scope.comment = Records.comments.build(parentId: $scope.parentComment.id, discussionId: $scope.parentComment.discussionId, authorId: Session.user().id)
      $scope.comment.parentAuthorName = $scope.parentComment.authorName()
      $scope.submit = FormService.submit $scope, $scope.comment,
        drafts: true
        submitFn: $scope.comment.save
        flashSuccess: ->
          if $scope.comment.isReply()
            'comment_form.messages.replied'
          else
            'comment_form.messages.created'
        flashOptions:
          name: ->
            $scope.comment.parent().authorName() if $scope.comment.isReply()

        successCallback: $scope.init
      KeyEventService.submitOnEnter $scope
      $scope.$broadcast 'reinitializeForm', $scope.comment
    $scope.init()

    AttachmentService.listenForAttachments $scope, $scope.comment
