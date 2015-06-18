angular.module('loomioApp').controller 'ProposalRedirectController', ($router, $rootScope, $routeParams, $location, Records, LmoUrlService) ->
  $rootScope.$broadcast('currentComponent', 'proposalRedirect')
  Records.proposals.findOrFetchByKey($routeParams.key).then (proposal) =>
    Records.discussions.findOrFetchByKey(proposal.discussionId).then (discussion) =>
      $location.url LmoUrlService.discussion discussion,
        proposal: proposal.key
        position: $location.search().position

  return
