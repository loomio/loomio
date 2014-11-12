angular.module('loomioApp').factory 'VoteModel', (RecordStoreService, $sanitize) ->
  class VoteModel
    constructor: (data = {}) ->
      @id = data.id
      @authorId = data.author_id
      @proposalId = data.motion_id
      @position = data.position
      @statement = data.statement
      @createdAt = data.created_at

    params: ->
      vote:
        id: @id
        motion_id: @proposalId
        position: @position
        statement: @statement

    plural: 'votes'

    author: ->
      RecordStoreService.get('users', @authorId)

    proposal: ->
      RecordStoreService.get('proposals', @proposalId)

    authorName: ->
      @author().name

    positionVerb: ->
      switch @position
        when 'yes' then 'agree'
        when 'no' then 'disagree'
        else @position # abstain and block are the same

    hasStatement: ->
      @statement? && @statement.toString().length > 0

    anyPosition: ->
      @position

    isAgree: ->
      @position == 'yes'

    isDisagree: ->
      @position == 'no'

    isAbstain: ->
      @position == 'abstain'

    isBlock: ->
      @position == 'block'

