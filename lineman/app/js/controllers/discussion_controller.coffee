angular.module('loomioApp').controller 'DiscussionController', ($scope, discussion, eventSubscription, currentUser, EventService) ->
  PrivatePub.sign(eventSubscription)

  PrivatePub.subscribe "/events", (data, channel) ->
    EventService.consumeEventFromResponseData(data)
    $scope.$apply()

  $scope.currentUser = currentUser
  $scope.discussion = discussion

  $scope.safeEvent = (kind) ->
    _.contains ['new_comment', 'new_motion'], kind

  $scope.$on 'replyToCommentClicked', (event, originalComment) ->
    $scope.$broadcast('showReplyToCommentForm', originalComment)
