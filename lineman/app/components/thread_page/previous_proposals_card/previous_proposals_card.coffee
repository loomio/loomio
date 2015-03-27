angular.module('loomioApp').directive 'previousProposalsCard', ->
  scope: {}
  bindToController: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/previous_proposals_card/previous_proposals_card.html'
  replace: true
  controllerAs: 'previousProposalsCard'
  controller: (Records, ProposalFormService) ->

    @selectedProposal = {}

    @proposals = ->
      @discussion.closedProposals()

    @isSelected = (proposal) ->
      proposal.id == @selectedProposal.id

    @selectProposal = (proposal) =>
      @selectedProposal = proposal

    return
