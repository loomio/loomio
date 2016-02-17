angular.module('loomioApp').directive 'proposalsCard', ->
  scope: {}
  bindToController: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposals_card/proposals_card.html'
  replace: true
  controllerAs: 'proposalsCard'
  controller: (Records, ProposalFormService, CurrentUser) ->
    Records.proposals.fetchByDiscussion @discussion
    Records.votes.fetchMyVotes @discussion

    @isExpanded = (proposal) ->
      if @selectedProposal?
        proposal.id == @selectedProposal.id
      else
        proposal.isActive()

    @selectProposal = (proposal) =>
      @selectedProposal = proposal

    @canStartProposal = =>
      AbilityService.canStartProposal(@discussion)

    return
