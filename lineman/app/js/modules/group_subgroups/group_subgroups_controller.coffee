angular.module('loomioApp').controller 'GroupSubgroupsController', ($scope, GroupService, RecordStoreService) ->
  GroupService.fetchByParent $scope.group
