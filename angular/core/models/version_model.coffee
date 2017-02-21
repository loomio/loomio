angular.module('loomioApp').factory 'VersionModel', (BaseModel) ->
  class VersionModel extends BaseModel
    @singular: 'version'
    @plural: 'versions'
    @indices: ['discussionId']

    relationships: ->
      @belongsTo 'discussion'
      @belongsTo 'comment'
      @belongsTo 'proposal'
      @belongsTo 'poll'
      @belongsTo 'author', from: 'users', by: 'whodunnit'

    editedAttributeNames: ->
      _.filter _.keys(@changes).sort(), (key) ->
        _.include ['title', 'name', 'description', 'closing_at', 'private', 'attachment_ids'], key

    attributeEdited: (name) ->
       _.include(_.keys(@changes), name)

    model: ->
      @discussion() or @comment()

    isCurrent: ->
      @id == _.last(@model().versions())['id']

    isOriginal: ->
      @id == _.first(@model().versions())['id']

    authorOrEditorName: ->
      if @isOriginal()
        @model().authorName()
      else
        @author().name
