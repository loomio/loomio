angular.module('loomioApp').directive 'subgroupsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/subgroups_card/subgroups_card.html'
  replace: true
  controller: ($scope, Records, AbilityService) ->
    Records.groups.fetchByParent $scope.group

    $scope.canCreateSubgroups = ->
      AbilityService.canCreateSubgroups($scope.group)

    $scope.showSubgroupsPlaceholder = ->
      AbilityService.canAdministerGroup($scope.group) and $scope.group.subgroups().length == 0
