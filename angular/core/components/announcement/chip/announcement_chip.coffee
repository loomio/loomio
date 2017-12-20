angular.module('loomioApp').directive 'announcementChip', (AppConfig, Records) ->
  scope: {chip: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/chip/announcement_chip.html'
  controller: ($scope) ->

    $scope.$watch 'chip.icon_url', ->
      $scope.userForAvatar = Records.users.build(
        avatarKind:     (if $scope.chip.icon_url then 'uploaded' else 'initials')
        avatarUrl:      $scope.chip.icon_url
        avatarInitials: $scope.chip.avatar_initials
      ) if $scope.chip.type == 'User'
