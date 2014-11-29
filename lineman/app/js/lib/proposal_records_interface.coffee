angular.module('loomioApp').factory 'ProposalRecordsInterface', (BaseRecordsInterface, ProposalModel) ->
  class ProposalRecordsInterface extends BaseRecordsInterface
    @model: ProposalModel

    fetchByDiscussion: (discussion, success, failure) ->
      @restfulClient().fetch({discussion_id: discussion.id}, success, failure)

    close: (proposal, success, failure) ->
      @restfulClient().post("#{proposal.id}/close").then (response) ->
        success() if success?
      , (response) ->
        failure() if failure?
