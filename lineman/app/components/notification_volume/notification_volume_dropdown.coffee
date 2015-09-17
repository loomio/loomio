angular.module('loomioApp').directive 'notificationVolumeDropdown', ->
  scope: {translateRoot: '@', group: '=?', discussion: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/notification_volume/notification_volume_dropdown.html'
  replace: true
  controller: ($scope, FlashService, Records, CurrentUser) ->
    $scope.saveVolume = ->
      $scope.model.changeVolume($scope.model.volume).then ->
        FlashService.success "#{$scope.translateRoot}.volume.updated"

    $scope.volumeLevels = ["loud", "normal", "quiet", "mute"]

    $scope.iconClassForLevel = (level) ->
      switch level
        when 'loud' then 'fa-envelope'
        when 'normal' then 'fa-volume-up'
        when 'quiet' then 'fa-volume-down'
        when 'mute' then 'fa-volume-off'

    $scope.init = ->
      if $scope.group
        $scope.model = $scope.group.membershipFor(CurrentUser)
      else if $scope.discussion
        $scope.model = $scope.discussion

    $scope.init()
    return
