angular.module('loomioApp').controller 'ProposalRedirectController', ($router, $rootScope, $routeParams, $location, Records) ->
  $rootScope.$broadcast('currentComponent', 'proposalRedirect')
  Records.proposals.findOrFetchByKey($routeParams.key).then (proposal) =>
    @proposal = proposal
    $location.url("/d/#{proposal.discussionKey}")
  return
