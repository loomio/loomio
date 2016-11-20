angular.module('loomioApp').directive 'startProposalButton', ->
  scope: { discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/start_proposal_button/start_proposal_button.html'
  replace: true
  controller: ($scope, Records, ModalService, ProposalForm, AbilityService) ->

    $scope.canStartProposal = ->
      AbilityService.canStartProposal($scope.discussion)

    $scope.startProposal = ->
      ModalService.open ProposalForm, proposal: -> Records.proposals.build(discussionId: $scope.discussion.id)
