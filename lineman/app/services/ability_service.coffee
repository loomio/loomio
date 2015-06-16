angular.module('loomioApp').factory 'AbilityService', (CurrentUser) ->
  new class AbilityService
    canStartProposal: (thread) ->
      thread and
      !thread.hasActiveProposal() and
      (CurrentUser.isAdminOf(thread.group()) or
       thread.group().membersCanRaiseProposals)
