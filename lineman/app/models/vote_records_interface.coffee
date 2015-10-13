angular.module('loomioApp').factory 'VoteRecordsInterface', (BaseRecordsInterface, VoteModel) ->
  class VoteRecordsInterface extends BaseRecordsInterface
    model: VoteModel

    fetchMyVotes: (proposals) ->
      proposalIds = _.map proposals, (proposal) -> proposal.id
      @fetch
        path: 'my_votes'
        params:
          proposal_ids: proposalIds

    fetchByProposal: (proposal) ->
      @fetch
        params:
          motion_id: proposal.id
