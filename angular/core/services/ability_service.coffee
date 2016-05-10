angular.module('loomioApp').factory 'AbilityService', (AppConfig, Session) ->
  new class AbilityService

    isLoggedIn: ->
      Session.current().id? and ! Session.current().restricted?

    canAddComment: (thread) ->
      Session.current().isMemberOf(thread.group())

    canRespondToComment: (comment) ->
      Session.current().isMemberOf(comment.group())

    canStartProposal: (thread) ->
      thread and
      !thread.hasActiveProposal() and
      (@canAdministerGroup(thread.group()) or
      (Session.current().isMemberOf(thread.group()) and thread.group().membersCanRaiseMotions))

    canEditThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      Session.current().isMemberOf(thread.group()) and
      (Session.current().isAuthorOf(thread) or thread.group().membersCanEditDiscussions)

    canMoveThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      Session.current().isAuthorOf(thread)

    canDeleteThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      Session.current().isAuthorOf(thread)

    canChangeThreadVolume: (thread) ->
      Session.current().isMemberOf(thread.group())

    canChangeGroupVolume: (group) ->
      Session.current().isMemberOf(group)

    canVoteOn: (proposal) ->
      proposal.isActive() and
      Session.current().isMemberOf(proposal.group()) and
      (@canAdministerGroup(proposal.group()) or proposal.group().membersCanVote)

    canCloseOrExtendProposal: (proposal) ->
      proposal.isActive() and
      (@canAdministerGroup(proposal.group()) or Session.current().isAuthorOf(proposal))

    canEditProposal: (proposal) ->
      proposal.isActive() and
      proposal.canBeEdited() and
      (@canAdministerGroup(proposal.group()) or (Session.current().isMemberOf(proposal.group()) and Session.current().isAuthorOf(proposal)))

    canCreateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and !proposal.hasOutcome()

    canUpdateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and proposal.hasOutcome()

    canSetOutcomeFor: (proposal) ->
      proposal? and
      proposal.isClosed() and
      (Session.current().isAuthorOf(proposal) or @canAdministerGroup(proposal.group()))

    canAdministerGroup: (group) ->
      Session.current().isAdminOf(group)

    canManageGroupSubscription: (group) ->
      @canAdministerGroup(group) and
      group.subscriptionKind != 'trial' and
      group.subscriptionPaymentMethod != 'manual'

    isCreatorOf: (group) ->
      Session.current().id == group.creatorId

    canStartThread: (group) ->
      @canAdministerGroup(group) or
      (CurrentUser.isMemberOf(group) and group.membersCanStartDiscussions)

    canAddMembers: (group) ->
      @canAdministerGroup(group) or
      (Session.current().isMemberOf(group) and group.membersCanAddMembers)

    canCreateSubgroups: (group) ->
      group.isParent() and
      (@canAdministerGroup(group) or
      (Session.current().isMemberOf(group) and group.membersCanCreateSubgroups))

    canEditGroup: (group) ->
      @canAdministerGroup(group)

    canArchiveGroup: (group) ->
      @canAdministerGroup(group)

    canEditComment: (comment) ->
      Session.current().isMemberOf(comment.group()) and
      Session.current().isAuthorOf(comment) and
      (comment.isMostRecent() or comment.group().membersCanEditComments)

    canDeleteComment: (comment) ->
      (Session.current().isMemberOf(comment.group()) and
      Session.current().isAuthorOf(comment)) or
      @canAdministerGroup(comment.group())

    canRemoveMembership: (membership) ->
      membership.group().memberIds().length > 1 and
      (!membership.admin or membership.group().adminIds().length > 1) and
      (membership.user() == Session.current() or @canAdministerGroup(membership.group()))

    canDeactivateUser: ->
     _.all Session.current().memberships(), (membership) ->
       !membership.admin or membership.group().hasMultipleAdmins

    canManageMembershipRequests: (group) ->
      (group.membersCanAddMembers and Session.current().isMemberOf(group)) or @canAdministerGroup(group)

    canViewGroup: (group) ->
      !group.privacyIsSecret() or
      Session.current().isMemberOf(group)

    canViewPrivateContent: (group) ->
      CurrentUser.isMemberOf(group)

    canViewMemberships: (group) ->
      Session.current().isMemberOf(group)

    canViewPreviousProposals: (group) ->
      @canViewGroup(group)

    canJoinGroup: (group) ->
      (group.membershipGrantedUpon == 'request') and
      @canViewGroup(group) and
      !Session.current().isMemberOf(group)

    canRequestMembership: (group) ->
      (group.membershipGrantedUpon == 'approval') and
      @canViewGroup(group) and
      !Session.current().isMemberOf(group) and
      !group.hasPendingMembershipRequestFrom(Session.current())

    canTranslate: (model) ->
      AppConfig.canTranslate and
      Session.current().locale and
      Session.current().locale != model.author().locale
