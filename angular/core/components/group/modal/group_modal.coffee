angular.module('loomioApp').factory 'GroupModal', ->
  templateUrl: 'generated/components/group/modal/group_modal.html'
  controller: ($scope, group, Records) ->
    $scope.group = group.clone()

    $scope.currentStep = 'create'

    $scope.$on 'createComplete', (_, group) ->
      if !$scope.group.isNew() or $scope.group.parentId
        $scope.$close()
      else
        $scope.invitationForm = Records.invitationForms.build(groupId: group.id)
        $scope.currentStep = 'invite'

    $scope.$on 'inviteComplete', $scope.$close
