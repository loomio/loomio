angular.module('loomioApp').controller 'ProposalRedirectController', ($router, $timeout, $rootScope, $routeParams, $location, Records, LmoUrlService) ->
  $rootScope.$broadcast('currentComponent', 'proposalRedirect')
  Records.proposals.findOrFetchById($routeParams.key).then (proposal) =>
    Records.discussions.findOrFetchById(proposal.discussionId).then (discussion) =>
      params = {}
      if $location.search().position?
        params.position = $location.search().position
        $location.search 'position', null
      $timeout -> $location.path LmoUrlService.proposal proposal, params
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  return
