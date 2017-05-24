angular.module('loomioApp').directive 'pollCommonPreview', (PollService, Session) ->
  scope: {poll: '=', displayGroupName: '=?'}
  templateUrl: 'generated/components/poll/common/preview/poll_common_preview.html'
  controller: ($scope) ->

    $scope.formattedPollType = (type) ->
      _.capitalize type.replace('_', '-')

    $scope.showGroupName = ->
      $scope.displayGroupName && $scope.poll.group()
