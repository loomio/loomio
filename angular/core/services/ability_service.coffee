angular.module('loomioApp').factory 'AbilityService', (AppConfig, Session) ->
  new class AbilityService

    isLoggedIn: =>
      @isUser() and !Session.user().restricted?

    isVisitor: ->
      AppConfig.currentVisitorId?

    isUser: ->
      AppConfig.currentUserId?

    canAddComment: (thread) ->
      Session.user().isMemberOf(thread.group())

    canRespondToComment: (comment) ->
      Session.user().isMemberOf(comment.group())

    canStartProposal: (thread) ->
      thread and
      !thread.hasActiveProposal() and
      (@canAdministerGroup(thread.group()) or
      (Session.user().isMemberOf(thread.group()) and thread.group().membersCanRaiseMotions))

    canStartPoll: (group) ->
      group and
      (@canAdministerGroup(group) or Session.user().isMemberOf(group) and group.membersCanRaiseMotions)

    canEditThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      Session.user().isMemberOf(thread.group()) and
      (Session.user().isAuthorOf(thread) or thread.group().membersCanEditDiscussions)

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

    canVoteOn: (proposal) ->
      proposal.isActive() and
      Session.user().isMemberOf(proposal.group()) and
      (@canAdministerGroup(proposal.group()) or proposal.group().membersCanVote)

    canCloseOrExtendProposal: (proposal) ->
      proposal.isActive() and
      (@canAdministerGroup(proposal.group()) or Session.user().isAuthorOf(proposal))

    canEditProposal: (proposal) ->
      proposal.isActive() and
      proposal.canBeEdited() and
      (@canAdministerGroup(proposal.group()) or (Session.user().isMemberOf(proposal.group()) and Session.user().isAuthorOf(proposal)))

    canCreateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and !proposal.hasOutcome()

    canUpdateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and proposal.hasOutcome()

    canSetOutcomeFor: (proposal) ->
      proposal? and
      proposal.isClosed() and
      (Session.user().isAuthorOf(proposal) or @canAdministerGroup(proposal.group()))

    canAdministerGroup: (group) ->
      Session.user().isAdminOf(group)

    canManageGroupSubscription: (group) ->
      @canAdministerGroup(group) and
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

    canViewGroup: (group) ->
      !group.privacyIsSecret() or
      Session.user().isMemberOf(group)

    canViewPrivateContent: (group) ->
      Session.user().isMemberOf(group)

    canCreateContentFor: (group) ->
      Session.user().isMemberOf(group)

    canViewMemberships: (group) ->
      Session.user().isMemberOf(group)

    canViewPreviousProposals: (group) ->
      @canViewGroup(group)

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

    canSharePoll: (poll) ->
      @canEditPoll(poll)

    canEditPoll: (poll) ->
      poll.isActive() and @canAdministerPoll(poll)

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
             'startPollPage' then true
        else false
