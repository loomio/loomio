angular.module('loomioApp').factory 'ProposalRecordsInterface', (BaseRecordsInterface, ProposalModel) ->
  class ProposalRecordsInterface extends BaseRecordsInterface
    model: ProposalModel

    fetchByDiscussion: (discussion, s, f) ->
      @restfulClient.getCollection(discussion_key: discussion.key)
