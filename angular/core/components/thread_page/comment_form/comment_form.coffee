angular.module('loomioApp').directive 'commentForm', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_form/comment_form.html'
  replace: true
  controller: ($scope, $rootScope, FormService, Records, Session, KeyEventService, AbilityService, MentionService, AttachmentService, ScrollService, EmojiService, ModalService, SignInForm) ->

    $scope.$on 'remindUndecided', (event) ->
      return unless $scope.discussion.activeProposal()
      ScrollService.scrollTo('.comment-form__comment-field')
      undecided = _.map $scope.discussion.activeProposal().undecidedMembers(), (member) -> "@#{member.username}"
      $scope.comment.body = undecided.join(', ')

    $scope.showCommentForm = ->
      AbilityService.canAddComment($scope.discussion)

    $scope.isLoggedIn = AbilityService.isLoggedIn

    $scope.signIn = ->
      ModalService.open SignInForm

    $scope.threadIsPublic = ->
      $scope.discussion.private == false

    $scope.threadIsPrivate = ->
      $scope.discussion.private == true

    successMessage = ->
      if $scope.comment.isReply()
        'comment_form.messages.replied'
      else
        'comment_form.messages.created'
    successMessageName = ->
      if $scope.comment.isReply()
        $scope.comment.parent().authorName()

    $scope.listenForSubmitOnEnter = ->
      KeyEventService.submitOnEnter $scope
    $scope.$on 'voteCreated',     $scope.listenForSubmitOnEnter
    $scope.$on 'proposalCreated', $scope.listenForSubmitOnEnter

    $scope.init = ->
      $scope.comment = Records.comments.build(discussionId: $scope.discussion.id, authorId: Session.user().id)
      $scope.submit = FormService.submit $scope, $scope.comment,
        drafts: true
        submitFn: $scope.comment.save
        flashSuccess: successMessage
        flashOptions:
          name: successMessageName
        successCallback: $scope.init
      $scope.listenForSubmitOnEnter()
      $scope.$broadcast 'commentFormInit', $scope.comment
    $scope.init()

    $scope.$on 'replyToCommentClicked', (event, parentComment) ->
      $scope.comment.parentId = parentComment.id
      $scope.comment.parentAuthorName = parentComment.authorName()
      ScrollService.scrollTo('.comment-form__comment-field')

    $scope.bodySelector = '.comment-form__comment-field'
    EmojiService.listen $scope, $scope.comment, 'body', $scope.bodySelector
    AttachmentService.listenForPaste $scope
    MentionService.applyMentions $scope, $scope.comment
    AttachmentService.listenForAttachments $scope, $scope.comment
