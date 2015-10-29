angular.module('loomioApp').directive 'groupVolumeCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_volume_card/group_volume_card.html'
  replace: true
  controller: ($scope, ModalService, CurrentUser, ChangeVolumeForm, AppConfig) ->

    $scope.membership = ->
      $scope.group.membershipFor(CurrentUser)

    $scope.openChangeVolumeForm = ->
      ModalService.open ChangeVolumeForm, model: -> $scope.membership()

    $scope.canChangeVolume = ->
      CurrentUser.isMemberOf($scope.group)

    return
