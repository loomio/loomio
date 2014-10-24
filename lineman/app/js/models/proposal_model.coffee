angular.module('loomioApp').factory 'ProposalModel', (RecordStoreService) ->
  class ProposalModel
    constructor: (data = {}) ->
      @id = data.id
      @name = data.name
      @description = data.description
      @createdAt = data.created_at
      @closingAt = data.closing_at
      @closedAt = data.closed_at
      @authorId = data.author_id
      @discussionId = data.discussion_id
      #@voteIds = data.vote_ids
      @voteCounts = data.vote_counts

    params: ->
      id: @id
      discussion_id: @discussionId
      name: @name
      description: @description
      closing_at: @closingAt

    plural: 'proposals'

    author: ->
      RecordStoreService.get('users', @authorId)

    discussion: ->
      RecordStoreService.get('discussions', @discussionId)

    votes: ->
      RecordStoreService.get 'votes', (vote) =>
        vote.proposalId == @id

    authorName: ->
      @author().name

    isActive: ->
      @closedAt == null

    userHasVoted: (user) ->
      _.any @votes, (vote) ->
        vote.userId == user.id

    lastVoteByUser: (user) ->
      _.first(_.sortBy(@votes, (vote) -> vote.createdAt))

    pieChartData: ->
      [
        { value: @voteCounts.yes, color: '#90D490', label: 'Agree' },
        { value: @voteCounts.abstain, color: '#F0BB67', label: 'Abstain' }
        { value: @voteCounts.no, color: '#D49090', label: 'Disagree' }
        { value: @voteCounts.block, color: '#DD0000', label: 'Block' }
      ]
