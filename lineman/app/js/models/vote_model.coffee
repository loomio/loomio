angular.module('loomioApp').factory 'VoteModel', (BaseModel) ->
  class VoteModel extends BaseModel
    @singular: 'vote'
    @plural: 'votes'

    initialize: (data) ->
      @id = data.id
      @authorId = data.author_id
      @proposalId = data.proposal_id
      @position = data.position
      @statement = data.statement
      @createdAt = data.created_at

    serialize: ->
      vote:
        id: @id
        motion_id: @proposalId
        position: @position
        statement: @statement

    author: ->
      @recordStore.users.find(@authorId)

    proposal: ->
      @recordStore.proposals.find(@proposalId)

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

