angular.module('loomioApp').directive 'startProposalCard', ->
  scope: {}
  bindToController: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/start_proposal_card/start_proposal_card.html'
  replace: true
  controllerAs: 'startProposalCard'
  controller: (ProposalFormService, CurrentUser) ->

    @openForm = ->
      ProposalFormService.openStartProposalModal(@discussion)

    @canStartProposal = ->
      !@discussion.hasActiveProposal() and CurrentUser.canStartProposals(@discussion)

    return
