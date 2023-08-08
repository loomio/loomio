import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import Session          from '@/shared/services/session'
import { pick }         from 'lodash'

export default class DiscussionTemplateModel extends BaseModel
  @singular: 'discussionTemplate'
  @plural: 'discussionTemplates'
  @uniqueIndices: ['id', 'key']
  @indices: ['groupId']

  defaultValues: ->
    description: null
    descriptionFormat: 'html'
    processIntroduction: null
    processIntroductionFormat: 'html'
    title: null
    tags: []
    files: []
    imageFiles: []
    attachments: []
    linkPreviews: []
    maxDepth: 3
    newestFirst: false
    
  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'group'

  buildDiscussion: ->
    discussion = @recordStore.discussions.build()

    attrs = pick(@, Object.keys(@defaultValues()))
    attrs.discussionTemplateId = @id
    attrs.discussionTemplateKey = @key
    attrs.authorId = Session.user().id

    discussion.update(attrs)

    discussion