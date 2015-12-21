angular.module('loomioApp').factory 'AbilityService', (AppConfig, CurrentUser) ->
  new class AbilityService

    isLoggedIn: ->
      CurrentUser.id?

    canAddComment: (thread) ->
      CurrentUser.isMemberOf(thread.group())

    canRespondToComment: (comment) ->
      CurrentUser.isMemberOf(comment.group())

    canStartProposal: (thread) ->
      thread and
      !thread.hasActiveProposal() and
      (@canAdministerGroup(thread.group()) or
      (CurrentUser.isMemberOf(thread.group()) and thread.group().membersCanRaiseMotions))

    canEditThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      CurrentUser.isMemberOf(thread.group()) and
      (CurrentUser.isAuthorOf(thread) or thread.group().membersCanEditDiscussions)

    canMoveThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      CurrentUser.isAuthorOf(thread)

    canDeleteThread: (thread) ->
      @canAdministerGroup(thread.group()) or
      CurrentUser.isAuthorOf(thread)

    canChangeThreadVolume: (thread) ->
      CurrentUser.isMemberOf(thread.group())

    canChangeGroupVolume: (group) ->
      CurrentUser.isMemberOf(group)

    canVoteOn: (proposal) ->
      proposal.isActive() and
      CurrentUser.isMemberOf(proposal.group()) and
      (@canAdministerGroup(proposal.group()) or proposal.group().membersCanVote)

    canCloseOrExtendProposal: (proposal) ->
      proposal.isActive() and
      (@canAdministerGroup(proposal.group()) or CurrentUser.isAuthorOf(proposal))

    canEditProposal: (proposal) ->
      proposal.isActive() and
      proposal.canBeEdited() and
      (@canAdministerGroup(proposal.group()) or (CurrentUser.isMemberOf(proposal.group()) and CurrentUser.isAuthorOf(proposal)))

    canCreateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and !proposal.hasOutcome()

    canUpdateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and proposal.hasOutcome()

    canSetOutcomeFor: (proposal) ->
      proposal.isClosed() and
      (CurrentUser.isAuthorOf(proposal) or @canAdministerGroup(proposal.group()))

    canAdministerGroup: (group) ->
      CurrentUser.isAdminOf(group)

    isCreatorOf: (group) ->
      CurrentUser.id == group.creatorId

    canStartThread: (group) ->
      group.membersCanStartDiscussions or @canAdministerGroup(group)

    canAddMembers: (group) ->
      @canAdministerGroup(group) or
      (CurrentUser.isMemberOf(group) and group.membersCanAddMembers)

    canCreateSubgroups: (group) ->
      group.isParent() and
      (@canAdministerGroup(group) or
      (CurrentUser.isMemberOf(group) and group.membersCanCreateSubgroups))

    canEditGroup: (group) ->
      @canAdministerGroup(group)

    canArchiveGroup: (group) ->
      @canAdministerGroup(group)

    canEditComment: (comment) ->
      CurrentUser.isMemberOf(comment.group()) and
      CurrentUser.isAuthorOf(comment) and
      (comment.isMostRecent() or comment.group().membersCanEditComments)

    canDeleteComment: (comment) ->
      (CurrentUser.isMemberOf(comment.group()) and
      CurrentUser.isAuthorOf(comment)) or
      @canAdministerGroup(comment.group())

    canRemoveMembership: (membership) ->
      membership.group().memberIds().length > 1 and
      (!membership.admin or membership.group().adminIds().length > 1) and
      (membership.user() == CurrentUser or @canAdministerGroup(membership.group()))

    canDeactivateUser: ->
     _.all CurrentUser.memberships(), (membership) ->
       !membership.admin or membership.group().hasMultipleAdmins

    canManageMembershipRequests: (group) ->
      (group.membersCanAddMembers and CurrentUser.isMemberOf(group)) or @canAdministerGroup(group)

    canViewGroup: (group) ->
      !group.privacyIsSecret() or
      CurrentUser.isMemberOf(group)

    canViewMemberships: (group) ->
      CurrentUser.isMemberOf(group)

    canViewPreviousProposals: (group) ->
      CurrentUser.isMemberOf(group)

    canJoinGroup: (group) ->
      (group.membershipGrantedUpon == 'request') and
      @canViewGroup(group) and
      !CurrentUser.isMemberOf(group)

    canRequestMembership: (group) ->
      (group.membershipGrantedUpon == 'approval') and
      @canViewGroup(group) and
      !CurrentUser.isMemberOf(group) and
      !group.hasPendingMembershipRequestFrom(CurrentUser)

    canTranslate: (model) ->
      AppConfig.canTranslate and CurrentUser.locale != model.author().locale
