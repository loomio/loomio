angular.module('loomioApp').factory 'VoteRecordsInterface', (BaseRecordsInterface, VoteModel) ->
  class VoteRecordsInterface extends BaseRecordsInterface
    model: VoteModel

    fetchMyRecentVotes: ->
      @restfulClient.get('my_votes')

    fetchMyVotesByDiscussion: (discussion) ->
      @restfulClient.get('my_votes', discussion_key: discussion.key)

    fetchByProposal: (proposal) ->
      @restfulClient.getCollection(motion_id: proposal.id)
