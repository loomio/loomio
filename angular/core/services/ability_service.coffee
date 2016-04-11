angular.module('loomioApp').factory 'AbilityService', (AppConfig, User) ->
  new class AbilityService

    isLoggedIn: ->
      User.current().id?

    canAddComment: (thread) ->
      User.current().isMemberOf(thread.group())

    canRespondToComment: (comment) ->
      User.current().isMemberOf(comment.group())

    canStartProposal: (thread) ->
      thread and
      !thread.hasActiveProposal() and
      (@canAdministerGroup(thread.group()) or
      (User.current().isMemberOf(thread.group()) and thread.group().membersCanRaiseMotions))

    canEditThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      User.current().isMemberOf(thread.group()) and
      (User.current().isAuthorOf(thread) or thread.group().membersCanEditDiscussions)

    canMoveThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      User.current().isAuthorOf(thread)

    canDeleteThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      User.current().isAuthorOf(thread)

    canChangeThreadVolume: (thread) ->
      User.current().isMemberOf(thread.group())

    canChangeGroupVolume: (group) ->
      User.current().isMemberOf(group)

    canVoteOn: (proposal) ->
      proposal.isActive() and
      User.current().isMemberOf(proposal.group()) and
      (@canAdministerGroup(proposal.group()) or proposal.group().membersCanVote)

    canCloseOrExtendProposal: (proposal) ->
      proposal.isActive() and
      (@canAdministerGroup(proposal.group()) or User.current().isAuthorOf(proposal))

    canEditProposal: (proposal) ->
      proposal.isActive() and
      proposal.canBeEdited() and
      (@canAdministerGroup(proposal.group()) or (User.current().isMemberOf(proposal.group()) and User.current().isAuthorOf(proposal)))

    canCreateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and !proposal.hasOutcome()

    canUpdateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and proposal.hasOutcome()

    canSetOutcomeFor: (proposal) ->
      proposal? and
      proposal.isClosed() and
      (User.current().isAuthorOf(proposal) or @canAdministerGroup(proposal.group()))

    canAdministerGroup: (group) ->
      User.current().isAdminOf(group)

    canManageGroupSubscription: (group) ->
      @canAdministerGroup(group) and
      group.subscriptionKind != 'trial' and
      group.subscriptionPaymentMethod != 'manual'

    isCreatorOf: (group) ->
      User.current().id == group.creatorId

    canStartThread: (group) ->
      group.membersCanStartDiscussions or @canAdministerGroup(group)

    canAddMembers: (group) ->
      @canAdministerGroup(group) or
      (User.current().isMemberOf(group) and group.membersCanAddMembers)

    canCreateSubgroups: (group) ->
      group.isParent() and
      (@canAdministerGroup(group) or
      (User.current().isMemberOf(group) and group.membersCanCreateSubgroups))

    canEditGroup: (group) ->
      @canAdministerGroup(group)

    canArchiveGroup: (group) ->
      @canAdministerGroup(group)

    canEditComment: (comment) ->
      User.current().isMemberOf(comment.group()) and
      User.current().isAuthorOf(comment) and
      (comment.isMostRecent() or comment.group().membersCanEditComments)

    canDeleteComment: (comment) ->
      (User.current().isMemberOf(comment.group()) and
      User.current().isAuthorOf(comment)) or
      @canAdministerGroup(comment.group())

    canRemoveMembership: (membership) ->
      membership.group().memberIds().length > 1 and
      (!membership.admin or membership.group().adminIds().length > 1) and
      (membership.user() == User.current() or @canAdministerGroup(membership.group()))

    canDeactivateUser: ->
     _.all User.current().memberships(), (membership) ->
       !membership.admin or membership.group().hasMultipleAdmins

    canManageMembershipRequests: (group) ->
      (group.membersCanAddMembers and User.current().isMemberOf(group)) or @canAdministerGroup(group)

    canViewGroup: (group) ->
      !group.privacyIsSecret() or
      User.current().isMemberOf(group)

    canViewMemberships: (group) ->
      User.current().isMemberOf(group)

    canViewPreviousProposals: (group) ->
      group.privacyIsOpen() or
      User.current().isMemberOf(group)

    canJoinGroup: (group) ->
      (group.membershipGrantedUpon == 'request') and
      @canViewGroup(group) and
      !User.current().isMemberOf(group)

    canRequestMembership: (group) ->
      (group.membershipGrantedUpon == 'approval') and
      @canViewGroup(group) and
      !User.current().isMemberOf(group) and
      !group.hasPendingMembershipRequestFrom(User.current())

    canTranslate: (model) ->
      AppConfig.canTranslate and
      User.current().locale and
      User.current().locale != model.author().locale
