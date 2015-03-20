angular.module('loomioApp').directive 'proposalsCard', ->
  scope: {}
  bindToController: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposals_card/proposals_card.html'
  replace: true
  controllerAs: 'proposalsCard'
  controller: (Records, ProposalFormService) ->
    console.log 'proposalsCard.discussion', @discussion

    Records.proposals.fetchByDiscussion @discussion
    Records.votes.fetchMyVotesByDiscussion @discussion

    @openForm = ->
      ProposalFormService.openStartProposalModal(@discussion)

    @isExpanded = (proposal) ->
      if @selectedProposal?
        proposal.id == @selectedProposal.id
      else
        proposal.isActive()

    @selectProposal = (proposal) =>
      @selectedProposal = proposal

    @canStartProposal = =>
      !@discussion.hasActiveProposal() and window.Loomio.currentUser.canStartProposals(@discussion)
    return
