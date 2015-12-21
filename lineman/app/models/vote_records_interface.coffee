angular.module('loomioApp').factory 'VoteRecordsInterface', (BaseRecordsInterface, VoteModel) ->
  class VoteRecordsInterface extends BaseRecordsInterface
    model: VoteModel

    fetchMyVotes: (model) ->
      params = {}
      params["#{model.constructor.singular}_id"] = model.id
      @fetch
        path: 'my_votes'
        params: params

    fetchByProposal: (proposal) ->
      @fetch
        params:
          motion_id: proposal.id
