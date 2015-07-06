angular.module('loomioApp').factory 'ProposalRecordsInterface', (BaseRecordsInterface, ProposalModel) ->
  class ProposalRecordsInterface extends BaseRecordsInterface
    model: ProposalModel

    fetchByDiscussion: (discussion) ->
      @fetch
        params:
          discussion_key: discussion.key
        cacheKey: "proposalsFor#{discussion.key}"

    createOutcome: (proposal) ->
      @restfulClient.postMember proposal.id, "create_outcome",
        motion:
          outcome: proposal.outcome

    createOutcome: (proposal) ->
      @restfulClient.postMember proposal.id, "update_outcome",
        motion:
          outcome: proposal.outcome

    fetchUndecidedMembers: (proposal) ->
      if proposal.isActive()
        @recordStore.memberships.fetchByGroup(proposal.group().key, {per: 500})
      else
        @recordStore.didNotVotes.fetchByProposal(proposal.key, {per: 500})
