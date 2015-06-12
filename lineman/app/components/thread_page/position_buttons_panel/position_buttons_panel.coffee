angular.module('loomioApp').directive 'positionButtonsPanel', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/position_buttons_panel/position_buttons_panel.html'
  replace: true
  controller: ($scope, ModalService, VoteForm, CurrentUser) ->

    $scope.undecided = ->
      !($scope.proposal.lastVoteByUser(CurrentUser)?)


    $scope.select = (position) ->
      proposal_fn = -> $scope.proposal
      position_fn = -> position
      ModalService.open(VoteForm, proposal: proposal_fn, position: position_fn)

