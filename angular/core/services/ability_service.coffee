angular.module('loomioApp').factory 'AbilityService', (AppConfig, Records, Session) ->
  new class AbilityService

    isLoggedIn: ->
      @isUser() and !Session.user().restricted?

    isEmailVerified: ->
      @isLoggedIn() && Session.user().emailVerified

    isUser: ->
      AppConfig.currentUserId?

    canContactUser: (user) ->
      @isLoggedIn() &&
      Session.user().id != user.id &&
      _.intersection(Session.user().groupIds(), user.groupIds()).length

    canAddComment: (thread) ->
      Session.user().isMemberOf(thread.group())

    canRespondToComment: (comment) ->
      Session.user().isMemberOf(comment.group())

    canStartPoll: (group) ->
      group and
      (@canAdministerGroup(group) or Session.user().isMemberOf(group) and group.membersCanRaiseMotions)

    canParticipateInPoll: (poll) ->
      return false unless poll
      @canAdministerPoll(poll) or
      !poll.group() or
      (Session.user().isMemberOf(poll.group()) and poll.group().membersCanVote)

    canReactToPoll: (poll) ->
      @isEmailVerified() and @canParticipateInPoll(poll)

    canEditStance: (stance) ->
      Session.user() == stance.author()

    canEditThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      Session.user().isMemberOf(thread.group()) and
      (Session.user().isAuthorOf(thread) or thread.group().membersCanEditDiscussions)

    canPinThread: (thread) ->
      !thread.pinned && @canAdministerGroup(thread.group())

    canUnpinThread: (thread) ->
      thread.pinned && @canAdministerGroup(thread.group())

    canMoveThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      Session.user().isAuthorOf(thread)

    canDeleteThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      Session.user().isAuthorOf(thread)

    canChangeThreadVolume: (thread) ->
      Session.user().isMemberOf(thread.group())

    canChangeGroupVolume: (group) ->
      Session.user().isMemberOf(group)

    canAdministerGroup: (group) ->
      Session.user().isAdminOf(group)

    canAdministerDiscussion: (discussion) ->
      Session.user().isAuthorOf(discussion) or
      @canAdministerGroup(discussion.group())

    canManageGroupSubscription: (group) ->
      group.isParent() and
      @canAdministerGroup(group) and
      group.subscriptionKind? and
      group.subscriptionKind != 'trial' and
      group.subscriptionPaymentMethod != 'manual'

    isCreatorOf: (group) ->
      Session.user().id == group.creatorId

    canStartThread: (group) ->
      @canAdministerGroup(group) or
      (Session.user().isMemberOf(group) and group.membersCanStartDiscussions)

    canAddMembers: (group) ->
      @canAdministerGroup(group) or
      (Session.user().isMemberOf(group) and group.membersCanAddMembers)

    canAddDocuments: (group) ->
      @canAdministerGroup(group)

    canEditDocument: (group) ->
      @canAdministerGroup(group)

    canCreateSubgroups: (group) ->
      group.isParent() and
      (@canAdministerGroup(group) or
      (Session.user().isMemberOf(group) and group.membersCanCreateSubgroups))

    canEditGroup: (group) ->
      @canAdministerGroup(group)

    canArchiveGroup: (group) ->
      @canAdministerGroup(group)

    canEditComment: (comment) ->
      Session.user().isMemberOf(comment.group()) and
      Session.user().isAuthorOf(comment) and
      (comment.isMostRecent() or comment.group().membersCanEditComments)

    canDeleteComment: (comment) ->
      (Session.user().isMemberOf(comment.group()) and
      Session.user().isAuthorOf(comment)) or
      @canAdministerGroup(comment.group())

    canRemoveMembership: (membership) ->
      membership.group().memberIds().length > 1 and
      (!membership.admin or membership.group().adminIds().length > 1) and
      (membership.user() == Session.user() or @canAdministerGroup(membership.group()))

    canDeactivateUser: ->
     _.all Session.user().memberships(), (membership) ->
       !membership.admin or membership.group().hasMultipleAdmins

    canManageMembershipRequests: (group) ->
      (group.membersCanAddMembers and Session.user().isMemberOf(group)) or @canAdministerGroup(group)

    canViewPublicGroups: ->
      AppConfig.features.public_groups

    canStartGroups: ->
      AppConfig.features.create_group || Session.user().isAdmin

    canViewGroup: (group) ->
      !group.privacyIsSecret() or
      Session.user().isMemberOf(group)

    canViewPrivateContent: (group) ->
      Session.user().isMemberOf(group)

    canCreateContentFor: (group) ->
      Session.user().isMemberOf(group)

    canViewMemberships: (group) ->
      Session.user().isMemberOf(group)

    canViewPreviousPolls: (group) ->
      @canViewGroup(group)

    canJoinGroup: (group) ->
      (group.membershipGrantedUpon == 'request') and
      @canViewGroup(group) and
      !Session.user().isMemberOf(group)

    canRequestMembership: (group) ->
      (group.membershipGrantedUpon == 'approval') and
      @canViewGroup(group) and
      !Session.user().isMemberOf(group)

    canTranslate: (model) ->
      AppConfig.inlineTranslation.isAvailable? and
      _.contains(AppConfig.inlineTranslation.supportedLangs, Session.user().locale) and
      Session.user().locale != model.author().locale

    canSubscribeToPoll: (poll) ->
      if poll.group()
        @canViewGroup(poll.group())
      else
        @canAdministerPoll() || _.contains(@poll().voters(), Session.user())

    canSharePoll: (poll) ->
      @canEditPoll(poll)

    canEditPoll: (poll) ->
      poll.isActive() and @canAdministerPoll(poll)

    canDeletePoll: (poll) ->
      @canAdministerPoll(poll)

    canSetPollOutcome: (poll) ->
      poll.isClosed() and @canAdministerPoll(poll)

    canAdministerPoll: (poll) ->
      if poll.group()
        (@canAdministerGroup(poll.group()) or (Session.user().isMemberOf(poll.group()) and Session.user().isAuthorOf(poll)))
      else
        Session.user().isAuthorOf(poll)

    canClosePoll: (poll) ->
      @canEditPoll(poll)

    requireLoginFor: (page) ->
      return false if @isLoggedIn()
      switch page
        when 'emailSettingsPage' then !Session.user().restricted?
        when 'groupsPage',         \
             'dashboardPage',      \
             'inboxPage',          \
             'profilePage',        \
             'authorizedAppsPage', \
             'registeredAppsPage', \
             'registeredAppPage',  \
             'pollsPage',          \
             'startPollPage',      \
             'upgradePage',        \
             'startGroupPage' then true
        else false
