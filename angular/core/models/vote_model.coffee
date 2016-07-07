angular.module('loomioApp').factory 'VoteModel', (BaseModel, AppConfig) ->
  class VoteModel extends BaseModel
    @singular: 'vote'
    @plural: 'votes'
    @indices: ['id', 'proposalId']
    @serializableAttributes: AppConfig.permittedParams.vote

    defaultValues: ->
      statement: ''

    relationships: ->
      @belongsTo 'author', from: 'users'
      @belongsTo 'proposal'

    group: ->
      @proposal().group()

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

    charsLeft: ->
      250 - (@statement or '').toString().length

    overCharLimit: ->
      @charsLeft() < 0
