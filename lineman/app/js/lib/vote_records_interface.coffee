angular.module('loomioApp').factory 'VoteRecordsInterface', (BaseRecordsInterface, VoteModel) ->
  class VoteRecordsInterface extends BaseRecordsInterface
    model: VoteModel

    fetchMyVotesByDiscussion: (discussion, success, failure) ->
      @restfulClient.get('my_votes', discussion_key: discussion.key, @importAndInvoke(success), failure)

    fetchByProposal: (proposal, success, failure) ->
      @restfulClient.getCollection({motion_id: proposal.id}, @importAndInvoke(success), failure)
