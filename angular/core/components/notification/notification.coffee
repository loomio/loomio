angular.module('loomioApp').directive 'notification', ->
  scope: {notification: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notification/notification.html'
  replace: true
  controller: ($scope, $translate, Records) ->

    $scope.actor = $scope.notification.actor()
    if !$scope.actor and $scope.notification.kind == 'membership_requested'
      name = $scope.notification.translationValues.name
      $scope.actor = Records.users.build
        name:           name
        avatarInitials: name.toString().split(' ').map((n) -> n[0]).join('')
        avatarKind:     'initials'

    $scope.showProposalPie = ->
      !$scope.actor

    return
