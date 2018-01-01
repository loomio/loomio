AppConfig = require 'shared/services/app_config.coffee'
Records   = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'announcementChip', ->
  scope: {chip: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/chip/announcement_chip.html'
  controller: ['$scope', ($scope) ->
    $scope.$watch 'chip.icon_url', ->
      $scope.userForAvatar = Records.users.build(
        avatarKind:     (if $scope.chip.icon_url then 'uploaded' else 'initials')
        avatarUrl:      $scope.chip.icon_url
        avatarInitials: $scope.chip.avatar_initials
      ) if $scope.chip.type == 'User'
  ]
