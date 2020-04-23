import BaseModel from '@/shared/record_store/base_model'
import {filter, keys, includes} from 'lodash-es'

export default class VersionModel extends BaseModel
  @singular: 'version'
  @plural: 'versions'
  @indices: ['discussionId']

  relationships: ->
    @belongsTo 'discussion'
    @belongsTo 'comment'
    @belongsTo 'poll'
    @belongsTo 'author', from: 'users', by: 'whodunnit'

  editedAttributeNames: ->
    filter keys(@changes).sort(), (key) ->
      includes ['title', 'name', 'description', 'closing_at', 'private', 'document_ids'], key

  attributeEdited: (name) ->
     includes(keys(@changes), name)

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
