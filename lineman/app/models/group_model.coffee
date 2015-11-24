angular.module('loomioApp').factory 'GroupModel', (DraftableModel, AppConfig) ->
  class GroupModel extends DraftableModel
    @singular: 'group'
    @plural: 'groups'
    @uniqueIndices: ['id', 'key']
    @indices: ['parentId']
    @serializableAttributes: AppConfig.permittedParams.group
    @draftParent: 'draftParent'

    draftParent: ->
      @parent() or @recordStore.users.find(AppConfig.currentUserId)

    defaultValues: ->
      parentId: null
      name: ''
      description: ''
      groupPrivacy: 'closed'
      isVisibleToPublic: true
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
      @hasMany 'membershipRequests'
      @hasMany 'memberships'
      @hasMany 'invitations'
      @hasMany 'subgroups', from: 'groups', with: 'parentId', of: 'id'
      @belongsTo 'parent', from: 'groups'

    closedProposals: ->
      _.filter @proposals(), (proposal) ->
        proposal.isClosed()

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
        invitation.isPending()

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

    coverUrl: ->
      if @isSubgroup() && !@hasCustomCover
        @parent().coverUrl()
      else
        @coverUrlDesktop

    archive: =>
      @remote.patchMember(@key, 'archive').then =>
        @remove()
        _.each @memberships(), (m) -> m.remove()

    uploadPhoto: (file, kind) =>
      @remote.upload("#{@key}/upload_photo/#{kind}", file)

    trialIsOverdue: ->
      @subscriptionKind == 'trial' && @subscriptionExpiresAt.clone().add(1, 'days') < moment()

    noInvitationsSent: ->
      @membershipsCount < 2 and @invitationsCount < 2
