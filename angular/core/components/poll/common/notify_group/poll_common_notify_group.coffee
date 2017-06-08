angular.module('loomioApp').directive 'pollCommonNotifyGroup', ->
  scope: {model: '=', notifyAction: '@'}
  templateUrl: 'generated/components/poll/common/notify_group/poll_common_notify_group.html'
  controller: ($scope) ->

    if $scope.model
      $scope.notifyAction = $scope.notifyAction or $scope.model.notifyAction()
