angular.module('loomioApp').factory 'VersionModel', (BaseModel) ->
  class VersionModel extends BaseModel
    @singular: 'version'
    @plural: 'versions'
    @indices: ['discussionId']

    relationships: ->
      @belongsTo 'proposal'

    editedAttributeNames: ->
      _.filter _.keys(@changes).sort(), (key) ->
        _.include ['title', 'name', 'description', 'closing_at'], key

    attributeEdited: (name) ->
       _.include(_.keys(@changes), name)
