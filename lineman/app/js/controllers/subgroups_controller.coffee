angular.module('loomioApp').controller 'SubgroupsController', ($scope, GroupService, RecordStoreService) ->
  GroupService.fetchByParent $scope.group
