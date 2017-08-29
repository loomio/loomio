angular.module('loomioApp').factory 'NotifyGroupModal', (Records, LoadingService) ->
  templateUrl: 'generated/components/notify/group/modal/notify_group_modal.html'
  controller: ($scope, notified) ->
    $scope.init = ->
      $scope.notified = notified
      Records.memberships.fetchByGroup(notified.id, per: 1000).then ->
        Records.groups.findOrFetchById(notified.id).then (group) ->
          $scope.group = group
    LoadingService.applyLoadingFunction $scope, 'init'
    $scope.init()

    $scope.$on '$close', $scope.$close
