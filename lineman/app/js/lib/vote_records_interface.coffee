angular.module('loomioApp').factory 'VoteRecordsInterface', (BaseRecordsInterface, VoteModel) ->
  class VoteRecordsInterface extends BaseRecordsInterface
    @model: VoteModel

    fetchMyVotes: (discussion, success, failure) ->
      @fetch({ discussion_id: discussion.id }, success, failure, 'my_votes')

    fetchByProposal: (proposal, success, failure) ->
      @fetch({motion_id: proposal.id}, success, failure)
