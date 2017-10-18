angular.module('loomioApp').factory 'GroupModal', ($location, Records, SequenceService, LmoUrlService) ->
  templateUrl: 'generated/components/group/modal/group_modal.html'
  controller: ($scope, group) ->
    $scope.group = group.clone()

    SequenceService.applySequence $scope, ['create', 'invite'],
      createComplete: (_, g) ->
        $location.path LmoUrlService.group(g)
        if !$scope.group.isNew() or $scope.group.parentId
          $scope.$close()
        else
          $scope.invitationForm = Records.invitationForms.build(groupId: g.id)
      inviteComplete: ->
        $scope.$close()
