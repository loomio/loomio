angular.module('loomioApp').controller 'ProposalPieChartController', ($scope) ->

  $scope.pieChartData = [
    { value : 0, color : "#90D490" },
    { value : 0, color : "#F0BB67" },
    { value : 0, color : "#D49090" },
    { value : 0, color : "#dd0000"}
  ]

  $scope.pieChartOptions =
    animation: false
    segmentShowStroke : false
    responsive: false

  refreshPieChartData = ->
    return unless $scope.proposal
    counts = $scope.proposal.voteCounts
    # yeah - this is done to preseve the view binding on the pieChartData
    $scope.pieChartData[0].value = counts.yes
    $scope.pieChartData[1].value = counts.abstain
    $scope.pieChartData[2].value = counts.no
    $scope.pieChartData[3].value = counts.block

  $scope.$watch 'proposal.voteCounts', ->
    refreshPieChartData()
