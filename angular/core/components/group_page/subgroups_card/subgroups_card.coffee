angular.module('loomioApp').directive 'subgroupsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/subgroups_card/subgroups_card.html'
  replace: true
  controller: ($scope, $rootScope, Records, AbilityService, ModalService, GroupForm) ->
    Records.groups.fetchByParent($scope.group).then ->
      $rootScope.$broadcast('subgroupsLoaded', $scope.group)

    $scope.canCreateSubgroups = ->
      AbilityService.canCreateSubgroups($scope.group)

    $scope.startSubgroup = ->
       ModalService.open GroupForm, group: -> Records.groups.build(parentId: $scope.group.id)

    $scope.showSubgroupsCard = ->
      $scope.group.subgroups().length
