angular.module('loomioApp').factory 'VoteRecordsInterface', (BaseRecordsInterface, VoteModel) ->
  class VoteRecordsInterface extends BaseRecordsInterface
    model: VoteModel

    fetchMyRecentVotes: ->
      @fetch
        path: 'my_votes'
        cacheKey: 'myVotes'

    fetchMyVotesByDiscussion: (discussion) ->
      @fetch
        path: 'my_votes'
        params:
          discussion_key: discussion.key
        cacheKey: "myVotesFor#{discussion.key}" 

    fetchByProposal: (proposal) ->
      @fetch
        params:
          motion_id: proposal.id
        cacheKey: "votesFor#{proposal.key}"
