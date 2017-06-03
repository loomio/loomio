angular.module('loomioApp').factory 'GroupModal', ->
  templateUrl: 'generated/components/group/modal/group_modal.html'
  controller: ($scope, group) ->
    $scope.group = group.clone()

    $scope.currentStep = 'create'

    $scope.$on 'createComplete', ->
      if $scope.group.parentId
        $scope.$close()
      else
        $scope.currentStep = 'invite'

    $scope.$on 'inviteComplete', $scope.$close
