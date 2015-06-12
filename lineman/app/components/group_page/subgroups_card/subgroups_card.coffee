angular.module('loomioApp').directive 'subgroupsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/subgroups_card/subgroups_card.html'
  replace: true
  controller: ($scope, Records, CurrentUser) ->
    Records.groups.fetchByParent $scope.group

    $scope.canCreateSubgroups = ->
      CurrentUser.isMemberOf($scope.group) and
        ($scope.group.membersCanCreateSubgroups or CurrentUser.isAdminOf($scope.group))

    $scope.showSubgroupsPlaceholder = ->
      CurrentUser.isAdminOf($scope.group) and $scope.group.subgroups().length == 0
