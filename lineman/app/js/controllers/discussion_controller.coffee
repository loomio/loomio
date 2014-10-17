angular.module('loomioApp').controller 'DiscussionController', ($scope, discussion, eventSubscription, currentUser, EventService, RecordStoreService) ->
  $scope.currentUser = currentUser
  $scope.discussion = discussion

  $scope.onNewEventReceived = (event) ->
    $scope.discussion.eventIds.push event.id

  EventService.subscribeTo(eventSubscription, $scope.onNewEventReceived)

  $scope.safeEvent = (kind) ->
    _.contains ['new_comment', 'new_motion', 'new_vote'], kind

  $scope.$on 'replyToCommentClicked', (event, originalComment) ->
    $scope.$broadcast('showReplyToCommentForm', originalComment)
