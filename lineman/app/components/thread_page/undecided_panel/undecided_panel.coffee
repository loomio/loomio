angular.module('loomioApp').directive 'undecidedPanel', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/undecided_panel/undecided_panel.html'
  replace: true
  controller: ($scope, Records) ->

    $scope.undecidedPanelOpen = false

    $scope.showUndecided = ->
      Records.proposals.fetchUndecidedMembers($scope.proposal)
      $scope.undecidedPanelOpen = true

    $scope.hideUndecided = ->
      $scope.undecidedPanelOpen = false
