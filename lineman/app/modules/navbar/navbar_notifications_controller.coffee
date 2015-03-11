angular.module('loomioApp').controller 'NavbarNotificationsController', ($scope, UserAuthService, Records) ->
  $scope.currentUser = window.Loomio.currentUser

  Records.notifications.fetch()

  $scope.userLoggedIn = ->
    window.Loomio.currentUser?

  validKinds = [
    'comment_liked',
    'motion_closing_soon',
    'new_discussion',
    'new_motion',
    'motion_closed',
    'new_vote',
    'new_comment',
    'comment_liked',
    'comment_replied_to',
    'user_mentioned',
    'membership_requested',
    'membership_request_approved',
    'user_added_to_group',
    'motion_closing_soon',
    'motion_blocked',
    'motion_outcome_created',
    'motion_outcome_updated',
  ]

