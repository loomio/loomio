angular.module('loomioApp').directive 'commentForm', ($translate, FormService, Records, Session, KeyEventService, AbilityService, ScrollService, EmojiService) ->
  scope: {eventWindow: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_form/comment_form.html'
  replace: true
  controller: ($scope, $rootScope) ->
    $scope.discussion = $scope.eventWindow.discussion
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
        $translate.instant('comment_form.in_reply_to', name: $scope.comment.parent().author().name)
      else
        $translate.instant('comment_form.aria_label')

    $scope.$on 'setParentComment', (e, parentComment) ->
      $scope.comment.parentId = parentComment.id

    $scope.init = ->
      $scope.comment = Records.comments.build
        discussionId: $scope.discussion.id
        authorId: Session.user().id

      $scope.submit = FormService.submit $scope, $scope.comment,
        drafts: true
        submitFn: $scope.comment.save
        flashSuccess: ->
          $scope.$emit 'commentSaved'
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

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()
    $scope.signIn = -> ModalService.open AuthModal
