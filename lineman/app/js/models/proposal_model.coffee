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
      @voteIds = data.vote_ids
      @votesCount = data.votes_count

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
      RecordStoreService.getAll('votes', @voteIds)

    authorName: ->
      @author().name

    isActive: ->
      @closedAt == null

    pieChartData: ->
      [
        { value: data.yes_votes_count, color: '#90D490', label: 'Agree' },
        { value: data.abstain_votes_count, color: '#F0BB67', label: 'Abstain' }
        { value: data.no_votes_count, color: '#D49090', label: 'Disagree' }
        { value: data.block_votes_count, color: '#DD0000', label: 'Block' }
      ]
