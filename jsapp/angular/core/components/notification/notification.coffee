angular.module('loomioApp').directive 'notification', ->
  scope: {notification: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notification/notification.html'
  replace: true
  controller: ($scope, Records) ->
    $scope.actor = ->
      $scope.membershipRequestActor || $scope.notification.actor()

    if $scope.notification.kind == 'membership_requested'
      $scope.membershipRequestActor = Records.users.build
        name:           $scope.notification.translationValues.name
        avatarInitials: $scope.notification.translationValues.name.toString().split(' ').map((n) -> n[0]).join('')
        avatarKind:     'initials'

    return
