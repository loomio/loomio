angular.module('loomioApp').controller 'ProposalPieChartController', ($scope) ->

  $scope.pieChartData = [
    { value : 0, color : "#90D490" },
    { value : 0, color : "#F0BB67" },
    { value : 0, color : "#D49090" },
    { value : 0, color : "#dd0000" },
    { value : 0, color : "#cccccc" }
  ]

  $scope.pieChartOptions =
    animation: false
    segmentShowStroke: true
    segmentStrokeColor: "#fff"
    responsive: false

  refreshPieChartData = ->
    return unless $scope.proposal
    counts = $scope.proposal.voteCounts
    hasAnyVotes = counts.yes + counts.abstain + counts.no + counts.block > 0
    $scope.pieChartData[0].value = counts.yes
    $scope.pieChartData[1].value = counts.abstain
    $scope.pieChartData[2].value = counts.no
    $scope.pieChartData[3].value = counts.block
    $scope.pieChartData[4].value = if hasAnyVotes then 0 else 1

  $scope.$watch 'proposal.voteCounts', ->
    refreshPieChartData()
