angular.module('loomioApp').factory 'ProposalRecordsInterface', (BaseRecordsInterface, ProposalModel) ->
  class ProposalRecordsInterface extends BaseRecordsInterface
    model: ProposalModel

    fetchByDiscussion: (discussion) ->
      @fetch
        params:
          discussion_key: discussion.key
        cacheKey: "proposalsFor#{discussion.key}"
