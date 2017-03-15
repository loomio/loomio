angular.module('loomioApp').directive 'pollCommonPreview', (PollService, Session) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/preview/poll_common_preview.html'
  controller: ($scope) ->
    $scope.chartType = ->
      PollService.fieldFromTemplate($scope.poll.pollType, 'chart_type')

    $scope.myStance = ->
      PollService.lastStanceBy(Session.participant(), $scope.poll)
