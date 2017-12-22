angular.module('loomioApp').directive 'notification', ($translate) ->
  scope: {notification: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notification/notification.html'
  replace: true
  controller: ($scope, Records) ->
    $scope.actor = ->
      $scope.membershipRequestActor || $scope.notification.actor()

    $scope.contentFor = (notification) ->
      $translate.instant("notifications.#{$scope.notification.kind}", $scope.notification.translationValues)

    if $scope.notification.kind == 'membership_requested'
      $scope.membershipRequestActor = Records.users.build
        name:           $scope.notification.translationValues.name
        avatarInitials: $scope.notification.translationValues.name.toString().split(' ').map((n) -> n[0]).join('')
        avatarKind:     'initials'

    return
