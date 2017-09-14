angular.module('loomioApp').factory 'AbilityService', (AppConfig, Records, Session) ->
  new class AbilityService

    isLoggedIn: Records.memoize ->
      @isUser() and !Session.user().restricted?

    isEmailVerified: Records.memoize ->
      @isLoggedIn() && Session.user().emailVerified

    isUser: Records.memoize ->
      AppConfig.currentUserId?

    canContactUser: Records.memoize (user) ->
      @isLoggedIn() &&
      Session.user().id != user.id &&
      _.intersection(Session.user().groupIds(), user.groupIds()).length

    canAddComment: Records.memoize (thread) ->
      Session.user().isMemberOf(thread.group())

    canRespondToComment: Records.memoize (comment) ->
      Session.user().isMemberOf(comment.group())

    canStartPoll: Records.memoize (group) ->
      group and
      (@canAdministerGroup(group) or Session.user().isMemberOf(group) and group.membersCanRaiseMotions)

    canParticipateInPoll: Records.memoize (poll) ->
      return false unless poll
      @canAdministerPoll(poll) or
      !poll.group() or
      (Session.user().isMemberOf(poll.group()) and poll.group().membersCanVote)

    canEditStance: Records.memoize (stance) ->
      Session.user() == stance.author()

    canEditThread: Records.memoize (thread) ->
      @canAdministerGroup(thread.group()) or
      Session.user().isMemberOf(thread.group()) and
      (Session.user().isAuthorOf(thread) or thread.group().membersCanEditDiscussions)

    canPinThread: Records.memoize (thread) ->
      !thread.pinned && @canAdministerGroup(thread.group())

    canUnpinThread: Records.memoize (thread) ->
      thread.pinned && @canAdministerGroup(thread.group())

    canMoveThread: Records.memoize (thread) ->
      @canAdministerGroup(thread.group()) or
      Session.user().isAuthorOf(thread)

    canDeleteThread: Records.memoize (thread) ->
      @canAdministerGroup(thread.group()) or
      Session.user().isAuthorOf(thread)

    canChangeThreadVolume: Records.memoize (thread) ->
      Session.user().isMemberOf(thread.group())

    canChangeGroupVolume: Records.memoize (group) ->
      Session.user().isMemberOf(group)

    canAdministerGroup: Records.memoize (group) ->
      Session.user().isAdminOf(group)

    canManageGroupSubscription: Records.memoize (group) ->
      group.isParent() and
      @canAdministerGroup(group) and
      group.subscriptionKind? and
      group.subscriptionKind != 'trial' and
      group.subscriptionPaymentMethod != 'manual'

    isCreatorOf: Records.memoize (group) ->
      Session.user().id == group.creatorId

    canStartThread: Records.memoize (group) ->
      @canAdministerGroup(group) or
      (Session.user().isMemberOf(group) and group.membersCanStartDiscussions)

    canAddMembers: Records.memoize (group) ->
      @canAdministerGroup(group) or
      (Session.user().isMemberOf(group) and group.membersCanAddMembers)

    canCreateSubgroups: Records.memoize (group) ->
      group.isParent() and
      (@canAdministerGroup(group) or
      (Session.user().isMemberOf(group) and group.membersCanCreateSubgroups))

    canEditGroup: Records.memoize (group) ->
      @canAdministerGroup(group)

    canArchiveGroup: Records.memoize (group) ->
      @canAdministerGroup(group)

    canEditComment: Records.memoize (comment) ->
      Session.user().isMemberOf(comment.group()) and
      Session.user().isAuthorOf(comment) and
      (comment.isMostRecent() or comment.group().membersCanEditComments)

    canDeleteComment: Records.memoize (comment) ->
      (Session.user().isMemberOf(comment.group()) and
      Session.user().isAuthorOf(comment)) or
      @canAdministerGroup(comment.group())

    canRemoveMembership: Records.memoize (membership) ->
      membership.group().memberIds().length > 1 and
      (!membership.admin or membership.group().adminIds().length > 1) and
      (membership.user() == Session.user() or @canAdministerGroup(membership.group()))

    canDeactivateUser: Records.memoize ->
     _.all Session.user().memberships(), (membership) ->
       !membership.admin or membership.group().hasMultipleAdmins

    canManageMembershipRequests: Records.memoize (group) ->
      (group.membersCanAddMembers and Session.user().isMemberOf(group)) or @canAdministerGroup(group)

    canViewGroup: Records.memoize (group) ->
      !group.privacyIsSecret() or
      Session.user().isMemberOf(group)

    canViewPrivateContent: Records.memoize (group) ->
      Session.user().isMemberOf(group)

    canCreateContentFor: Records.memoize (group) ->
      Session.user().isMemberOf(group)

    canViewMemberships: Records.memoize (group) ->
      Session.user().isMemberOf(group)

    canViewPreviousPolls: Records.memoize (group) ->
      @canViewGroup(group)

    canJoinGroup: Records.memoize (group) ->
      (group.membershipGrantedUpon == 'request') and
      @canViewGroup(group) and
      !Session.user().isMemberOf(group)

    canRequestMembership: Records.memoize (group) ->
      (group.membershipGrantedUpon == 'approval') and
      @canViewGroup(group) and
      !Session.user().isMemberOf(group)

    canTranslate: Records.memoize (model) ->
      AppConfig.inlineTranslation.isAvailable? and
      _.contains(AppConfig.inlineTranslation.supportedLangs, Session.user().locale) and
      Session.user().locale != model.author().locale

    canSubscribeToPoll: Records.memoize (poll) ->
      if poll.group()
        @canViewGroup(poll.group())
      else
        @canAdministerPoll() || _.contains(@poll().voters(), Session.user())

    canSharePoll: Records.memoize (poll) ->
      @canEditPoll(poll)

    canEditPoll: Records.memoize (poll) ->
      poll.isActive() and @canAdministerPoll(poll)

    canDeletePoll: Records.memoize (poll) ->
      @canAdministerPoll(poll)

    canSetPollOutcome: Records.memoize (poll) ->
      poll.isClosed() and @canAdministerPoll(poll)

    canAdministerPoll: Records.memoize (poll) ->
      if poll.group()
        (@canAdministerGroup(poll.group()) or (Session.user().isMemberOf(poll.group()) and Session.user().isAuthorOf(poll)))
      else
        Session.user().isAuthorOf(poll)

    canClosePoll: Records.memoize (poll) ->
      @canEditPoll(poll)

    requireLoginFor: Records.memoize (page) ->
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
