import BaseModel    from '@/shared/record_store/base_model'
import AppConfig    from '@/shared/services/app_config'
import HasDocuments from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'
import {filter, some, map, each, compact} from 'lodash'

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
    groupPrivacy: 'secret'
    handle: null
    discussionPrivacyOptions: 'private_only'
    membershipGrantedUpon: 'approval'
    membersCanAnnounce: true
    membersCanAddMembers: true
    membersCanEditDiscussions: true
    membersCanEditComments: true
    membersCanRaiseMotions: true
    membersCanStartDiscussions: true
    membersCanCreateSubgroups: false
    motionsCanBeEdited: false
    parentMembersCanSeeDiscussions: false
    files: []
    imageFiles: []
    attachments: []
    subscription: {}
    specifiedVotersOnly: false
    recipientMessage: null
    recipientAudience: null
    recipientUserIds: []
    recipientEmails: []


  afterConstruction: ->
    if @privacyIsClosed()
      @allowPublicThreads = @discussionPrivacyOptions == 'public_or_private'
    HasDocuments.apply @, showTitle: true
    HasTranslations.apply @

  relationships: ->
    @hasMany 'discussions', find: {discardedAt: {$ne: null}}
    @hasMany 'polls', find: {discardedAt: {$ne: null}}
    @hasMany 'membershipRequests'
    @hasMany 'memberships'
    @hasMany 'allDocuments', from: 'documents', with: 'groupId', of: 'id'
    @hasMany 'subgroups', from: 'groups', with: 'parentId', of: 'id', orderBy: 'name'
    @belongsTo 'parent', from: 'groups'

  tags: ->
    @recordStore.tags.collection.chain().find(id: {$in: @tagIds}).simplesort('priority').data()

  parentOrSelf: ->
    if @parentId then @parent() else @

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

  selfAndSubgroups: ->
    @recordStore.groups.find(@selfAndSubgroupIds())

  selfAndSubgroupIds: ->
    [@id].concat(@recordStore.groups.find(parentId: @id).map (g) -> g.id)

  membershipFor: (user) ->
    @recordStore.memberships.find(groupId: @id, userId: user.id)[0]

  members: ->
    @recordStore.users.collection.find(id: {$in: @memberIds()})

  parentsAndSelf: ->
    @selfAndParents().reverse()

  selfAndParents: ->
    compact [@].concat(@parentId && @parent().parentsAndSelf())

  parentAndSelfMemberships: ->
    @recordStore.memberships.collection.find(groupId: {$in: @parentOrSelf().selfAndSubgroupIds()})

  parentAndSelfMembershipIds: ->
    @parentAndSelfMemberships().map (u) -> u.id

  parentAndSelfMembers: ->
    @recordStore.users.collection.find(id: {$in: @parentAndSelfMemberships().map (m) -> m.userId})

  parentAndSelfMemberIds: ->
    @parentAndSelfMembers().map (u) -> u.id

  membersInclude: (user) ->
    @membershipFor(user) || false

  adminsInclude: (user) ->
    @recordStore.memberships.find(groupId: @id, userId: user.id, admin: true)[0] || false

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
    if @parentId && !@hasCustomCover
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
