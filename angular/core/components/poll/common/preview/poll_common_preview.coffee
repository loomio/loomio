angular.module('loomioApp').directive 'pollCommonPreview', (PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/preview/poll_common_preview.html'
  controller: ($scope) ->
    $scope.chartType = ->
      PollService.fieldFromTemplate($scope.poll.pollType, 'chart_type')
