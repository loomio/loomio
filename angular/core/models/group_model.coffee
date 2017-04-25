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

    relationships: ->
      @hasMany 'discussions'
      @hasMany 'proposals'
      @hasMany 'polls'
      @hasMany 'membershipRequests'
      @hasMany 'memberships'
      @hasMany 'invitations'
      @hasMany 'subgroups', from: 'groups', with: 'parentId', of: 'id'
      @belongsTo 'parent', from: 'groups'

    parentOrSelf: ->
      if @isParent() then @ else @parent()

    group: -> @

    shareableInvitation: ->
      @recordStore.invitations.find(singleUse:false, groupId: @id)[0]

    closedProposals: ->
      _.filter @proposals(), (proposal) ->
        proposal.isClosed()

    closedPolls: ->
      _.filter @polls(), (poll) ->
        !poll.isActive()

    hasPreviousProposals: ->
      _.some @closedProposals()

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
      _.map @memberships(), (membership) -> membership.userId

    adminIds: ->
      _.map @adminMemberships(), (membership) -> membership.userId

    parentName: ->
      @parent().name if @parent()?

    privacyIsOpen: ->
      @groupPrivacy == 'open'

    privacyIsClosed: ->
      @groupPrivacy == 'closed'

    privacyIsSecret: ->
      @groupPrivacy == 'secret'

    allowPublicDiscussions: ->
      if @privacyIsClosed() && @isNew()
        true
      else
        @discussionPrivacyOptions != 'private_only'

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
        '/img/default-logo-medium.png'

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

    noInvitationsSent: ->
      @membershipsCount < 2 and @invitationsCount < 2

    isSubgroupOfSecretParent: ->
      @isSubgroup() && @parent().privacyIsSecret()
