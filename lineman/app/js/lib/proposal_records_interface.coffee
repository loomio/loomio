angular.module('loomioApp').factory 'ProposalRecordsInterface', (BaseRecordsInterface, ProposalModel) ->
  class ProposalRecordsInterface extends BaseRecordsInterface
    model: ProposalModel

    fetchByDiscussion: (discussion, success, failure) ->
      @restfulClient.getCollection({discussion_key: discussion.key}, @importAndInvoke(success), failure)

    close: (proposal, success, failure) ->
      @restfulClient.post("#{proposal.id}/close", {}, @importAndInvoke(success), failure)
