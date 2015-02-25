angular.module('loomioApp').controller 'DiscussionPageController', ($scope, $modal, discussion, Records, MessageChannelService, UserAuthService, DiscussionFormService) ->
  $scope.discussion = discussion

  # maybe not needed
  onMessageReceived = ->
    console.log 'on message received called, yay'
    $scope.$digest()

  MessageChannelService.subscribeTo("/discussion-#{discussion.key}", onMessageReceived)

  $scope.editDiscussion = ->
    DiscussionFormService.openEditDiscussionModal(discussion)

  $scope.$on 'replyToCommentClicked', (event, originalComment) ->
    $scope.$broadcast('showReplyToCommentForm', originalComment)

  $scope.canStartProposals = ->
    !discussion.hasActiveProposal() and UserAuthService.currentUser.canStartProposals($scope.discussion)

  $scope.showContextMenu = ->
    $scope.canEditDiscussion($scope.discussion)

  $scope.canEditDiscussion = ->
    UserAuthService.currentUser.canEditDiscussion($scope.discussion)
