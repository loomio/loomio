angular.module('loomioApp').factory 'ProposalModel', (RecordStoreService) ->
  class ProposalModel
    constructor: (data = {}) ->
      @id = data.id
      @name = data.name
      @description = data.description
      @created_at = data.created_at
      @closing_at = data.closing_at
      @author_id = data.author_id
      @discussion_id = data.discussion_id
      @vote_ids = data.vote_ids
      @votes_count = data.votes_count
      @pie_chart_data = [
        { value: data.yes_votes_count, color: '#90D490', label: 'Agree' },
        { value: data.abstain_votes_count, color: '#F0BB67', label: 'Abstain' }
        { value: data.no_votes_count, color: '#D49090', label: 'Disagree' }
        { value: data.block_votes_count, color: '#DD0000', label: 'Block' }
      ]

    plural: 'proposals'

    author: ->
      RecordStoreService.get('users', @author_id)

    discussion: ->
      RecordStoreService.get('discussions', @discussion_id)

    votes: ->
      RecordStoreService.getAll('votes', @vote_ids)

    author_name: ->
      @author().name
