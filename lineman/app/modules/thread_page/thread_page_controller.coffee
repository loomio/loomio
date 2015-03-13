angular.module('loomioApp').controller 'ThreadPageController', ($scope, $modal, discussion, Records, MessageChannelService, UserAuthService, DiscussionFormService) ->
  $scope.discussion = discussion
  $scope.group = discussion.group()

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
    !discussion.hasActiveProposal() and window.Loomio.currentUser.canStartProposals($scope.discussion)

  $scope.showContextMenu = ->
    $scope.canEditDiscussion($scope.discussion)

  $scope.canEditDiscussion = ->
    window.Loomio.currentUser.canEditDiscussion($scope.discussion)
