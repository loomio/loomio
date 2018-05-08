Session = require 'shared/services/session'

{ fieldFromTemplate, myLastStanceFor } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonChartPreview', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/chart_preview/poll_common_chart_preview.html'
  controller: ['$scope', ($scope) ->
    $scope.chartType = ->
      fieldFromTemplate($scope.poll.pollType, 'chart_type')

    $scope.myStance = ->
      myLastStanceFor($scope.poll)
  ]
