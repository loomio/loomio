angular.module('loomioApp').factory 'NotifyGroupModal', (Records, LoadingService) ->
  templateUrl: 'generated/components/notify/group/modal/notify_group_modal.html'
  controller: ($scope, groupId) ->
    $scope.init = ->
      Records.groups.findOrFetchById(groupId).then (group) => $scope.group = group
    LoadingService.applyLoadingFunction $scope, 'init'
    $scope.init()
