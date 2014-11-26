angular.module('loomioApp').controller 'NavbarNotificationsController', ($scope, NotificationService, UserAuthService, Records) ->
  NotificationService.fetch {}

  validKinds = [
    'comment_liked',
    'motion_closing_soon',
    'new_discussion',
    'new_motion',
    'motion_closed',
    'new_vote',
    'new_comment',
    'comment_liked',
    'user_mentioned',
    'membership_requested',
    'membership_request_approved',
    'user_added_to_group',
    'motion_closing_soon',
    'motion_blocked',
    'motion_outcome_created',
    'motion_outcome_updated',
  ]

  $scope.notifications = ->
    Records.notifications.find(userId: UserAuthService.currentUser.id)
