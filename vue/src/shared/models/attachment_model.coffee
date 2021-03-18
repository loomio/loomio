import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class AttachmentModel extends BaseModel
  @singular: 'attachment'
  @plural: 'attachments'
  @indices: ['recordType', 'recordId']

  @eventTypeMap:
    Group: 'groups'
    Discussion: 'discussions'
    Poll: 'polls'
    Outcome: 'outcomes'
    Stance: 'stances'
    Comment: 'comments'
    CommentVote: 'comments'
    Membership: 'memberships'
    MembershipRequest: 'membershipRequests'

  model: ->
    @recordStore[@constructor.eventTypeMap[@recordType]].find(@recordId)

  group: ->
    @model().group()

  relationships: ->
    @belongsTo 'author', from: 'users'

  isAnImage: ->
    @icon == 'image'
