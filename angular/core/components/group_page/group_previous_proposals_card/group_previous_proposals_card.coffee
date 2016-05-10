angular.module('loomioApp').directive 'groupPreviousProposalsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_previous_proposals_card/group_previous_proposals_card.html'
  replace: true
  controller: ($scope, Session, Records, AbilityService) ->
    if AbilityService.canViewPreviousProposals($scope.group)
      Records.proposals.fetchClosedByGroup($scope.group.key, per: 3).then ->
        Records.votes.fetchMyVotes($scope.group) if AbilityService.isLoggedIn()

    $scope.showPreviousProposals = ->
      AbilityService.canViewPreviousProposals($scope.group) and $scope.group.hasPreviousProposals()

    $scope.lastVoteByCurrentUser = (proposal) ->
      proposal.lastVoteByUser(Session.user())
