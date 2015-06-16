angular.module('loomioApp').factory 'AbilityService', (CurrentUser) ->
  new class AbilityService
    canStartProposal: (thread) ->
      !thread.hasActiveProposal() and
      (@canAdminister(thread.group()) or 
       thread.group().membersCanRaiseProposals)

    canCloseOrExtendProposal: (proposal) ->
      proposal.isActive() and
      (@canAdminister(proposal.group()) or CurrentUser.isAuthorOf(proposal))

    canEditProposal: (proposal) ->
      proposal.isActive() and
      proposal.canBeEdited() and
      (@canAdminister(proposal.group()) or CurrentUser.isAuthorOf(proposal))

    canCreateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and !proposal.hasOutcome()

    canUpdateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and proposal.hasOutcome()

    canSetOutcomeFor: (proposal) ->
      proposal.isClosed() and
      (CurrentUser.isAuthorOf(proposal) or @canAdminister(proposal.group()))

    canAdminister: (group) ->
      CurrentUser.isAdminOf(group)

    canAddMembers: (group) ->
      @canAdminister(group) or
      (CurrentUser.isMemberOf(group) and group.membersCanAddMembers)

    canCreateSubgroups: (group) ->
      @canAdminister(group) or
      (CurrentUser.isMemberOf(group) and group.membersCanCreateSubgroups)

    canEditGroup: (group) ->
      @canAdminister(group)

    canDeactivateGroup: (group) ->
      @canAdminister(group)
