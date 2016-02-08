angular.module('loomioApp').controller 'ProposalRedirectController', ($router, $rootScope, $routeParams, $location, Records, LmoUrlService) ->
  $rootScope.$broadcast('currentComponent', 'proposalRedirect')
  Records.proposals.findOrFetchById($routeParams.key).then (proposal) =>
    Records.discussions.findOrFetchById(proposal.discussionId).then (discussion) =>
      params = {proposal: proposal.key}
      if $location.search().position?
        params.position = $location.search().position
      $location.url LmoUrlService.discussion discussion, params

  return
