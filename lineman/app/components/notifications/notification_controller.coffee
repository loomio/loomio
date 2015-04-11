angular.module('loomioApp').controller 'NotificationController', ($scope, LmoUrlService, Records) ->


  $scope.event = $scope.notification.event()
  $scope.actor = $scope.event.actor()

  if $scope.event.kind == 'user_added_to_group' and $scope.event.membership().inviter() == null
    console.log 'found it', $scope.event.membership().inviterId

  $scope.link = ->

    switch $scope.event.kind
      when 'comment_liked' then LmoUrlService.comment($scope.event.comment())
      when 'comment_replied_to' then LmoUrlService.comment($scope.event.comment())
      when 'motion_closing_soon' then LmoUrlService.proposal($scope.event.proposal())
      when 'motion_outcome_created' then LmoUrlService.proposal($scope.event.proposal())
      when 'user_mentioned' then LmoUrlService.comment($scope.event.comment())
      when 'membership_requested' then LmoUrlService.group($scope.event.membershipRequest().group())
      when 'user_added_to_group' then LmoUrlService.group($scope.event.membership().group())
      when 'membership_request_approved' then LmoUrlService.group($scope.event.membership().group())
      else
        console.log $scope.event.kind, 'no link case yet'


  return
