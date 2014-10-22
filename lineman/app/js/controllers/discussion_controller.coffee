angular.module('loomioApp').controller 'DiscussionController', ($scope, discussion, eventSubscription, currentUser, EventService, RecordStoreService) ->
  $scope.currentUser = currentUser
  $scope.discussion = discussion
  console.log discussion
  console.log RecordStoreService.get('events')
  console.log discussion.events()

  eventReceived = (event) ->
    console.log('hey we gots da event')
    #$scope.$apply()

  EventService.subscribeTo(eventSubscription, eventReceived)

  $scope.safeEvent = (kind) ->
    _.contains ['new_comment', 'new_motion', 'new_vote'], kind

  $scope.$on 'replyToCommentClicked', (event, originalComment) ->
    $scope.$broadcast('showReplyToCommentForm', originalComment)
