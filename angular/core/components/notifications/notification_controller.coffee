angular.module('loomioApp').controller 'NotificationController', ($scope, LmoUrlService, Records) ->


  $scope.event = $scope.notification.event()
  $scope.actor = $scope.event.actor()

  $scope.link = ->

    switch $scope.event.kind
      when 'comment_liked' then LmoUrlService.comment($scope.event.comment())
      when 'comment_replied_to' then LmoUrlService.comment($scope.event.comment())
      when 'motion_closing_soon' then LmoUrlService.proposal($scope.event.proposal())
      when 'motion_outcome_created' then LmoUrlService.proposal($scope.event.proposal())
      when 'user_mentioned' then LmoUrlService.comment($scope.event.comment())
      when 'membership_requested' then LmoUrlService.route(model: $scope.event.membershipRequest().group(), action: 'membership_requests')
      when 'user_added_to_group' then LmoUrlService.group($scope.event.membership().group())
      when 'membership_request_approved' then LmoUrlService.group($scope.event.membership().group())

  return
