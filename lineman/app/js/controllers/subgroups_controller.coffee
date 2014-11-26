angular.module('loomioApp').controller 'SubgroupsController', ($scope, GroupService) ->
  GroupService.fetchByParent $scope.group
