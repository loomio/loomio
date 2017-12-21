angular.module('loomioApp').directive 'subgroupsCard', ($rootScope, Records, AbilityService, ModalService, GroupModal) ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/subgroups_card/subgroups_card.html'
  replace: true
  controller: ($scope) ->
    $scope.show = ->
      $scope.group.isParent()

    Records.groups.fetchByParent($scope.group).then ->
      $rootScope.$broadcast('subgroupsLoaded', $scope.group)

    $scope.canCreateSubgroups = ->
      AbilityService.canCreateSubgroups($scope.group)

    $scope.startSubgroup = ->
       ModalService.open GroupModal, group: -> Records.groups.build(parentId: $scope.group.id)
