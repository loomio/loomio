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
