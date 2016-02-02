angular.module('loomioApp').directive 'groupVolumeCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_volume_card/group_volume_card.html'
  replace: true
  controller: ($scope, ModalService, CurrentUser, AbilityService, ChangeMembershipVolumeForm) ->
    $scope.membership = ->
      $scope.group.membershipFor(CurrentUser)

    $scope.openChangeVolumeForm = ->
      ModalService.open ChangeMembershipVolumeForm, group: -> $scope.group

    $scope.canChangeVolume = ->
      AbilityService.canChangeGroupVolume($scope.group)

    return
