import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class DocumentModel extends BaseModel
  @singular: 'document'
  @plural: 'documents'
  @indices: ['modelId', 'authorId']

  relationships: ->
    @belongsTo 'author', from: 'users', by: 'authorId'
    @belongsTo 'group'

  model: ->
    @recordStore["#{@modelType.toLowerCase()}s"].find(@modelId)

  modelTitle: ->
    switch @modelType
      when 'Group'      then @model().name
      when 'Discussion' then @model().title
      when 'Outcome'    then @model().poll().title
      when 'Comment'    then @model().discussion().title
      when 'Poll'       then @model().title

  authorName: ->
    @author().nameWithTitle(@model()) if @author()

  isAnImage: ->
    @icon == 'image'
