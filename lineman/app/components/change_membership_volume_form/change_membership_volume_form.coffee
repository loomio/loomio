angular.module('loomioApp').factory 'ChangeMembershipVolumeForm', ->
  templateUrl: 'generated/components/change_membership_volume_form/change_membership_volume_form.html'
  controller: ($scope, group, CurrentUser, FormService) ->
    groupName = group.name
    $scope.membership = group.membershipFor(CurrentUser).clone()
    $scope.volumeLevels = ["loud", "normal", "quiet", "mute"]

    $scope.submit = FormService.submit $scope, $scope.membership,
      flashSuccess: -> "group_volume_form.messages.#{$scope.membership.volume}"
      flashOptions:
        name: groupName

    return
