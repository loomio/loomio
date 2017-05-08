angular.module('loomioApp').directive 'notification', ->
  scope: {notification: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notification/notification.html'
  replace: true
  controller: ($scope, Records) ->
    $scope.actor = ->
      $scope.notification.actor() or $scope.membershipActor()

    $scope.membershipActor = ->
      return unless $scope.notification.kind == 'membership_requested'
      name = $scope.notification.translationValues.name
      Records.users.build
        name:           name
        avatarInitials: name.toString().split(' ').map((n) -> n[0]).join('')
        avatarKind:     'initials'

    return
