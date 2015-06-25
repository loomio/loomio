angular.module('loomioApp').factory 'AbilityService', (CurrentUser) ->
  new class AbilityService
    canStartProposal: (thread) ->
      thread and
      !thread.hasActiveProposal() and
      (@canAdministerGroup(thread.group()) or 
       thread.group().membersCanRaiseProposals)

    canEditThread: (thread) ->
      CurrentUser.isMemberOf(thread.group()) and
      (@canAdministerGroup(thread.group()) or
      CurrentUser.isAuthorOf(thread) or
      thread.group().membersCanEditDiscussions)

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
      (@canAdministerGroup(proposal.group()) or CurrentUser.isAuthorOf(proposal))

    canCreateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and !proposal.hasOutcome()

    canUpdateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and proposal.hasOutcome()

    canSetOutcomeFor: (proposal) ->
      proposal.isClosed() and
      (CurrentUser.isAuthorOf(proposal) or @canAdministerGroup(proposal.group()))

    canAdministerGroup: (group) ->
      CurrentUser.isAdminOf(group)

    canAddMembers: (group) ->
      @canAdministerGroup(group) or
      (CurrentUser.isMemberOf(group) and group.membersCanAddMembers)

    canCreateSubgroups: (group) ->
      @canAdministerGroup(group) or
      (CurrentUser.isMemberOf(group) and group.membersCanCreateSubgroups)

    canEditGroup: (group) ->
      @canAdministerGroup(group)

    canArchiveGroup: (group) ->
      @canAdministerGroup(group)

    canEditComment: (comment) ->
      CurrentUser.isAuthorOf(comment) and
      comment.isMostRecent() or comment.group().membersCanEditComments

    canDeleteComment: (comment) ->
      CurrentUser.isAuthorOf(comment) or
      @canAdministerGroup(comment.group())

    canRemoveMembership: (membership) ->
      membership.group().memberIds().length > 1 and
      (!membership.admin or membership.group().adminIds().length > 1) and
      (membership.user() == CurrentUser or @canAdministerGroup(membership.group()))
