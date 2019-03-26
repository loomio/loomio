BaseModel = require 'shared/record_store/base_model'

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
      _.includes ['title', 'name', 'description', 'closing_at', 'private', 'document_ids'], key

  attributeEdited: (name) ->
     _.includes(_.keys(@changes), name)

  authorName: ->
    @author().nameWithTitle(@model()) if @author()

  model: ->
    @recordStore["#{@itemType.toLowerCase()}s"].find(@itemId)

  isCurrent: ->
    @index == @model().versionsCount - 1

  isOriginal: ->
    @index == 0

  authorOrEditorName: ->
    if @isOriginal()
      @model().authorName()
    else
      @authorName()
