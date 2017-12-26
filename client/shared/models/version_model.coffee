BaseModel = require 'shared/models/base_model.coffee'

_ = require 'lodash'

module.exports = class VersionModel extends BaseModel
  @singular: 'version'
  @plural: 'versions'
  @indices: ['discussionId']

  relationships: ->
    @belongsTo 'discussion'
    @belongsTo 'comment'
    @belongsTo 'poll'
    @belongsTo 'author', from: 'users', by: 'whodunnit'

  editedAttributeNames: ->
    _.filter _.keys(@changes).sort(), (key) ->
      _.include ['title', 'name', 'description', 'closing_at', 'private', 'document_ids'], key

  attributeEdited: (name) ->
     _.include(_.keys(@changes), name)

  model: ->
    @recordStore["#{@itemType.toLowerCase()}s"].find(@itemId)

  isCurrent: ->
    @id == _.last(@model().versions())['id']

  isOriginal: ->
    @id == _.first(@model().versions())['id']

  authorOrEditorName: ->
    if @isOriginal()
      @model().authorName()
    else
      @author().name
