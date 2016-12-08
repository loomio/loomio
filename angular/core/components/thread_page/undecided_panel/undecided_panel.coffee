angular.module('loomioApp').directive 'undecidedPanel', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/undecided_panel/undecided_panel.html'
  replace: true
  controller: ($scope, $timeout, $rootScope, Records, ScrollService) ->

    $scope.undecidedPanelOpen = false

    $scope.showUndecided = ->
      $scope.proposal.fetchUndecidedMembers()
      $scope.undecidedPanelOpen = true
      $timeout ->
        document.querySelector('.undecided-panel__heading').focus()

    $scope.hideUndecided = ->
      $scope.undecidedPanelOpen = false

    $scope.remindUndecided = ->
      $rootScope.$broadcast 'remindUndecided'
