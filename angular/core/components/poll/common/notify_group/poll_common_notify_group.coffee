angular.module('loomioApp').directive 'pollCommonNotifyGroup', ->
  scope: {model: '='}
  templateUrl: 'generated/components/poll/common/notify_group/poll_common_notify_group.html'
  controller: ($scope) ->
    $scope.canMakeAnnouncement = ->
      (!$scope.model.isNew() && $scope.model.stancesCount > 0) || $scope.model.group()
