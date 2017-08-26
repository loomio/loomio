angular.module('loomioApp').factory 'ReactionModel', (BaseModel) ->
  class ReactionModel extends BaseModel
    @singular: 'reaction'
    @plural: 'reactions'
    @indices: ['userId', 'reactableId']

    relationships: ->
      @belongsTo 'user'

    reactable: ->
      Records["#{@reactableType.toLowerCase()}s"].find(@reactableId)
