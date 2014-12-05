angular.module('loomioApp').controller 'DiscussionController', ($scope, $modal, discussion, Records, MessageChannelService, FileUploadService, UserAuthService) ->
  $scope.discussion = discussion

  onMessageReceived = ->
    console.log 'on message received called, yay'
    $scope.$digest()

  MessageChannelService.subscribeTo("/discussion-#{discussion.key}", onMessageReceived)

  $scope.wrap = {}
  nextPage = 1

  busy = false
  $scope.lastPage = false

  $scope.editDiscussion = ->
    modalInstance = $modal.open
      templateUrl: 'generated/js/modules/discussion_page/discussion_form.html',
      controller: 'DiscussionFormController',
      resolve:
        discussion: -> $scope.discussion.copy()

  $scope.getNextPage = ->
    return false if busy or $scope.lastPage
    busy = true
    Records.events.fetch(discussion_key: discussion.key, page: nextPage).then (data) ->
      events = data.events
      $scope.lastPage = true if events.length == 0
      nextPage = nextPage + 1
      busy = false

  $scope.getNextPage()

  $scope.safeEvent = (kind) ->
    _.contains ['new_comment', 'new_motion', 'new_vote'], kind

  $scope.$on 'replyToCommentClicked', (event, originalComment) ->
    $scope.$broadcast('showReplyToCommentForm', originalComment)

  $scope.canStartProposals = ->
    !discussion.hasActiveProposal() and UserAuthService.currentUser.canStartProposals($scope.discussion)

  $scope.showContextMenu = ->
    $scope.canEditDiscussion($scope.discussion)

  $scope.canEditDiscussion = ->
    UserAuthService.currentUser.canEditDiscussion($scope.discussion)

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned
