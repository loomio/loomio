import BaseModel    from '@/shared/record_store/base_model'
import AppConfig    from '@/shared/services/app_config'
import HasDocuments from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'
import {filter, some, map, each} from 'lodash-es'

export default class GroupModel extends BaseModel
  @singular: 'group'
  @plural: 'groups'
  @uniqueIndices: ['id', 'key']
  @indices: ['parentId']

  defaultValues: ->
    parentId: null
    name: ''
    description: ''
    descriptionFormat: 'html'
    groupPrivacy: 'closed'
    handle: null
    discussionPrivacyOptions: 'private_only'
    membershipGrantedUpon: 'approval'
    membersCanAnnounce: true
    membersCanAddMembers: true
    membersCanEditDiscussions: true
    membersCanEditComments: true
    membersCanRaiseMotions: true
    membersCanVote: true
    membersCanStartDiscussions: true
    membersCanCreateSubgroups: false
    motionsCanBeEdited: false
    files: []
    imageFiles: []
    attachments: []

  afterConstruction: ->
    if @privacyIsClosed()
      @allowPublicThreads = @discussionPrivacyOptions == 'public_or_private'
    HasDocuments.apply @, showTitle: true
    HasTranslations.apply @

  relationships: ->
    @hasMany 'discussions'
    @hasMany 'polls'
    @hasMany 'membershipRequests'
    @hasMany 'memberships'
    @hasMany 'allDocuments', from: 'documents', with: 'groupId', of: 'id'
    @hasMany 'subgroups', from: 'groups', with: 'parentId', of: 'id', orderBy: 'name'
    @belongsTo 'parent', from: 'groups'

  parentOrSelf: ->
    if @parent() then @parent() else @

  group: -> @

  fetchToken: ->
    @remote.getMember(@id, 'token').then => @token

  resetToken: ->
    @remote.postMember(@id, 'reset_token').then => @token

  pendingMembershipRequests: ->
    filter @membershipRequests(), (membershipRequest) ->
      membershipRequest.isPending()

  hasPendingMembershipRequests: ->
    some @pendingMembershipRequests()

  hasPendingMembershipRequestFrom: (user) ->
    some @pendingMembershipRequests(), (request) ->
      request.requestorId == user.id

  previousMembershipRequests: ->
    filter @membershipRequests(), (membershipRequest) ->
      !membershipRequest.isPending()

  hasPreviousMembershipRequests: ->
    some @previousMembershipRequests()

  pendingInvitations: ->
    filter @invitations(), (invitation) ->
      invitation.isPending() and invitation.singleUse

  hasPendingInvitations: ->
    some @pendingInvitations()

  hasSubgroups: ->
    @isParent() && @subgroups().length

  publicOrganisationIds: ->
    map(filter(@subgroups().concat(@), (group) -> group.groupPrivacy == 'open'), 'id')

  organisationIds: ->
    map(@subgroups(), 'id').concat(@id)

  membershipFor: (user) ->
    @recordStore.memberships.find(groupId: @id, userId: user.id)[0]

  members: ->
    @recordStore.users.find(id: {$in: @memberIds()})

  membersInclude: (user) ->
    @membershipFor(user)
  adminsInclude: (user) ->
    @recordStore.memberships.find(groupId: @id, userId: user.id, admin: true)[0]

  adminMemberships: ->
    @recordStore.memberships.find(groupId: @id, admin: true)

  admins: ->
    @recordStore.users.find(id: {$in: @adminIds()})

  memberIds: ->
    map @memberships(), 'userId'

  adminIds: ->
    map @adminMemberships(), 'userId'

  parentName: ->
    @parent().name if @parent()?

  privacyIsOpen: ->
    @groupPrivacy == 'open'

  privacyIsClosed: ->
    @groupPrivacy == 'closed'

  privacyIsSecret: ->
    @groupPrivacy == 'secret'

  isArchived: ->
    @archivedAt?

  isParent: ->
    !@parentId?

  logoUrl: ->
    if @logoUrlMedium
      @logoUrlMedium
    else if @parent()
      @parent().logoUrl()
    else
      AppConfig.theme.icon_src

  coverUrl: (size = 'large') ->
    if @parent() && !@hasCustomCover
      @parent().coverUrl(size)
    else
      @coverUrls[size]

  archive: =>
    @remote.patchMember(@key, 'archive').then =>
      @remove()
      each @memberships(), (m) -> m.remove()

  export: =>
    @remote.postMember(@id, 'export')

  uploadLogo: (file) =>
    @remote.upload("#{@key}/upload_photo/logo", file, {}, ->)

  uploadCover: (file) =>
    @remote.upload("#{@key}/upload_photo/cover_photo", file, {}, ->)

  hasSubscription: ->
    @subscriptionKind?

  isSubgroupOfSecretParent: ->
    @parent() && @parent().privacyIsSecret()
