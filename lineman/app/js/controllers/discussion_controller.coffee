angular.module('loomioApp').controller 'DiscussionController', ($scope, discussion, eventSubscription, currentUser, EventService) ->
  $scope.currentUser = currentUser
  $scope.discussion = discussion

  newEventReceived = (event) =>
    $scope.$apply()

  #EventService.subscribeTo(eventSubscription, newEventReceived)

  $scope.safeEvent = (kind) ->
    _.contains ['new_comment', 'new_motion'], kind

  $scope.$on 'replyToCommentClicked', (event, originalComment) ->
    $scope.$broadcast('showReplyToCommentForm', originalComment)

