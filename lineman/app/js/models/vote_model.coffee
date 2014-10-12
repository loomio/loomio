angular.module('loomioApp').factory 'VoteModel', (RecordStoreService) ->
  class VoteModel
    constructor: (data = {}) ->
      @id = data.id
      @author_id = data.author_id
      @proposal_id = data.proposal_id
      @position = data.position
      @statement = data.statement

    plural: 'votes'

    author: ->
      RecordStoreService.get('users', @author_id)

    proposal: ->
      RecordStoreService.get('proposals', @proposal_id)

    author_name: ->
      @author().name

