angular.module('loomioApp').directive 'commentForm', ($translate) ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_form/comment_form.html'
  replace: true
  controller: ($scope, $rootScope, FormService, Records, Session, KeyEventService, AbilityService, MentionService, AttachmentService, ScrollService, EmojiService, ModalService, AuthModal) ->

    $scope.showCommentForm = ->
      AbilityService.canAddComment($scope.discussion)

    $scope.commentHelptext = ->
      helptext = if $scope.discussion.private
        $translate.instant 'comment_form.private_privacy_notice', groupName: $scope.comment.group().fullName
      else
        $translate.instant 'comment_form.public_privacy_notice'
      helptext.replace('&amp;', '&')
              .replace('&lt;', '<')
              .replace('&gt;', '>')

    $scope.commentPlaceholder = ->
      if $scope.comment.parentId
        $translate.instant('comment_form.in_reply_to', name: $scope.comment.parent().authorName())
      else
        $translate.instant('comment_form.say_something')

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()
    $scope.signIn = -> ModalService.open AuthModal

    $scope.init = ->
      $scope.comment = Records.comments.build(discussionId: $scope.discussion.id, authorId: Session.user().id)
      $scope.submit = FormService.submit $scope, $scope.comment,
        # drafts: true
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

    $scope.$on 'replyToCommentClicked', (event, parentComment) ->
      $scope.comment.parentId = parentComment.id
      $scope.comment.parentAuthorName = parentComment.authorName()
      ScrollService.scrollTo('.comment-form textarea', offset: 150)

    AttachmentService.listenForAttachments $scope, $scope.comment
