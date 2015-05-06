angular.module('loomioApp').directive 'startProposalCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/start_proposal_card/start_proposal_card.html'
  replace: true
  controller: ($scope, ProposalFormService, CurrentUser) ->

    $scope.openForm = ->
      ProposalFormService.openStartProposalModal($scope.discussion)

    $scope.canStartProposal = ->
      $scope.discussion && !$scope.discussion.hasActiveProposal() and CurrentUser.canStartProposals($scope.discussion)

    return
