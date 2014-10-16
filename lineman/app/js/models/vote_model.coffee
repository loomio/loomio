angular.module('loomioApp').factory 'VoteModel', (RecordStoreService, $sanitize) ->
  class VoteModel
    constructor: (data = {}) ->
      @id = data.id
      @authorId = data.author_id
      @proposalId = data.proposal_id
      @position = data.position
      @statement = data.statement

    plural: 'votes'

    author: ->
      RecordStoreService.get('users', @authorId)

    proposal: ->
      RecordStoreService.get('proposals', @proposalId)

    authorName: ->
      @author().name

    isAgree: ->
      @position == 'yes'

    isDisagree: ->
      @position == 'no'

    isAbstain: ->
      @position == 'abstain'

    isBlock: ->
      @position == 'block'

