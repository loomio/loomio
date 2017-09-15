angular.module('loomioApp').factory 'GroupModel', (DraftableModel, AppConfig) ->
  class GroupModel extends DraftableModel
    @singular: 'group'
    @plural: 'groups'
    @uniqueIndices: ['id', 'key']
    @indices: ['parentId']
    @serializableAttributes: AppConfig.permittedParams.group
    @draftParent: 'draftParent'
    @draftPayloadAttributes: ['name', 'description']

    draftParent: ->
      @parent() or @recordStore.users.find(AppConfig.currentUserId)

    defaultValues: ->
      parentId: null
      name: ''
      description: ''
      groupPrivacy: 'closed'
      discussionPrivacyOptions: 'private_only'
      membershipGrantedUpon: 'approval'
      membersCanAddMembers: true
      membersCanEditDiscussions: true
      membersCanEditComments: true
      membersCanRaiseMotions: true
      membersCanVote: true
      membersCanStartDiscussions: true
      membersCanCreateSubgroups: false
      motionsCanBeEdited: false

    afterConstruction: ->
      if @privacyIsClosed()
        @allowPublicThreads = @discussionPrivacyOptions == 'public_or_private'

    relationships: ->
      @hasMany 'discussions'
      @hasMany 'polls'
      @hasMany 'membershipRequests'
      @hasMany 'memberships'
      @hasMany 'invitations'
      @hasMany 'groupIdentities'
      @hasMany 'subgroups', from: 'groups', with: 'parentId', of: 'id'
      @belongsTo 'parent', from: 'groups'

    parentOrSelf: ->
      if @isParent() then @ else @parent()

    group: -> @

    shareableInvitation: ->
      @recordStore.invitations.find(singleUse:false, groupId: @id)[0]

    closedPolls: ->
      _.filter @polls(), (poll) ->
        !poll.isActive()

    activePolls: ->
      _.filter @polls(), (poll) ->
        poll.isActive()

    pendingMembershipRequests: ->
      _.filter @membershipRequests(), (membershipRequest) ->
        membershipRequest.isPending()

    hasPendingMembershipRequests: ->
      _.some @pendingMembershipRequests()

    hasPendingMembershipRequestFrom: (user) ->
       _.some @pendingMembershipRequests(), (request) ->
        request.requestorId == user.id

    previousMembershipRequests: ->
      _.filter @membershipRequests(), (membershipRequest) ->
        !membershipRequest.isPending()

    hasPreviousMembershipRequests: ->
      _.some @previousMembershipRequests()

    pendingInvitations: ->
      _.filter @invitations(), (invitation) ->
        invitation.isPending() and invitation.singleUse

    hasPendingInvitations: ->
      _.some @pendingInvitations()

    organisationDiscussions: ->
      @recordStore.discussions.find(groupId: { $in: @organisationIds() }, discussionReaderId: { $ne: null })

    organisationIds: ->
      _.pluck(@subgroups(), 'id').concat(@id)

    organisationSubdomain: ->
      if @isSubgroup()
        @parent().subdomain
      else
        @subdomain

    memberships: ->
      @recordStore.memberships.find(groupId: @id)

    membershipFor: (user) ->
      _.find @memberships(), (membership) -> membership.userId == user.id

    members: ->
      @recordStore.users.find(id: {$in: @memberIds()})

    adminMemberships: ->
      _.filter @memberships(), (membership) -> membership.admin

    admins: ->
      adminIds = _.map(@adminMemberships(), (membership) -> membership.userId)
      @recordStore.users.find(id: {$in: adminIds})

    coordinatorsIncludes: (user) ->
      _.some @recordStore.memberships.where(groupId: @id, userId: user.id)

    memberIds: ->
      _.pluck @memberships(), 'userId'

    adminIds: ->
      _.pluck @adminMemberships(), 'userId'

    parentName: ->
      @parent().name if @parent()?

    privacyIsOpen: ->
      @groupPrivacy == 'open'

    privacyIsClosed: ->
      @groupPrivacy == 'closed'

    privacyIsSecret: ->
      @groupPrivacy == 'secret'

    isSubgroup: ->
      @parentId?

    isArchived: ->
      @archivedAt?

    isParent: ->
      !@parentId?

    logoUrl: ->
      if @logoUrlMedium
        @logoUrlMedium
      else if @isSubgroup()
        @parent().logoUrl()
      else
        AppConfig.theme.default_group_logo_src

    coverUrl: (size) ->
      if @isSubgroup() && !@hasCustomCover
        @parent().coverUrl(size)
      else
        @coverUrls[size] || @coverUrls.small

    archive: =>
      @remote.patchMember(@key, 'archive').then =>
        @remove()
        _.each @memberships(), (m) -> m.remove()

    uploadPhoto: (file, kind) =>
      @remote.upload("#{@key}/upload_photo/#{kind}", file, {}, ->)

    hasSubscription: ->
      @subscriptionKind?

    isSubgroupOfSecretParent: ->
      @isSubgroup() && @parent().privacyIsSecret()

    groupIdentityFor: (type) ->
      _.find @groupIdentities(), (gi) ->
        gi.userIdentity().identityType == type
