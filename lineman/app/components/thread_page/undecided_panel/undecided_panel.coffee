angular.module('loomioApp').directive 'undecidedPanel', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/undecided_panel/undecided_panel.html'
  replace: true
  controller: ($scope, Records, CurrentUser) ->

    $scope.undecidedPanelOpen = false

    $scope.showUndecided = ->
      Records.memberships.fetchByGroup($scope.proposal.group().key, {per: 500})
      $scope.undecidedPanelOpen = true
