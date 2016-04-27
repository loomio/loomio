angular.module('loomioApp').directive 'positionButtonsPanel', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/position_buttons_panel/position_buttons_panel.html'
  replace: true
  controller: ($scope, ModalService, VoteForm, User, Records, AbilityService) ->

    $scope.showPositionButtons = ->
      AbilityService.canVoteOn($scope.proposal) and $scope.undecided()

    $scope.undecided = ->
      !($scope.proposal.lastVoteByUser(User.current())?)

    $scope.$on 'triggerVoteForm', (event, position) ->
      myVote = $scope.proposal.lastVoteByUser(User.current()) or {}
      $scope.select position, myVote.statement

    $scope.select = (position) ->
      ModalService.open(VoteForm, vote: -> Records.votes.build(proposalId: $scope.proposal.id, position: position))
