angular.module('loomioApp').directive 'startProposalCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/start_proposal_card/start_proposal_card.html'
  replace: true
  controller: ($scope, CurrentUser, ModalService, ProposalForm, Records) ->

    $scope.openForm = ->
      ModalService.open ProposalForm, proposal: -> Records.proposals.initialize(discussion_id: $scope.discussion.id)

    $scope.canStartProposal = ->
      $scope.discussion && !$scope.discussion.hasActiveProposal() and CurrentUser.canStartProposals($scope.discussion)

    return
