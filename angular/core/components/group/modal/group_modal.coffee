angular.module('loomioApp').factory 'GroupModal', ($location, Records, SequenceService, LmoUrlService) ->
  templateUrl: 'generated/components/group/modal/group_modal.html'
  controller: ($scope, group) ->
    $scope.group = group.clone()

    SequenceService.applySequence $scope,
      steps: ->
        if $scope.group.isNew() or $scope.group.parentId
          ['create', 'invite']
        else
          ['create']
      createComplete: (_, g) ->
        $scope.invitationForm = Records.invitationForms.build(groupId: g.id)
        $location.path LmoUrlService.group(g)
