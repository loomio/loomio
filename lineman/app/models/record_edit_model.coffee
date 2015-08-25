angular.module('loomioApp').factory 'RecordEditModel', (BaseModel) ->
  class RecordEditModel extends BaseModel
    @singular: 'recordEdit'
    @plural: 'recordEdits'
    @indices: ['id', 'discussionId']

    editedAttributeNames: ->
      _.filter _.keys(@previousValues).sort(), (key) ->
        _.include ['title', 'name', 'description', 'closing_at'], key

    attributeEdited: (name) ->
       _.include(_.keys(@newValues), name)

    proposal: ->
      @recordStore.proposals.find(@proposalId)
