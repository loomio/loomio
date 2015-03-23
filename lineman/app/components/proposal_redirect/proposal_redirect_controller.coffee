angular.module('loomioApp').controller 'ProposalRedirectController', ($router, $routeParams, Records) ->
  Records.proposals.findOrFetchByKey($routeParams.key).then (proposal) =>
    $router.navigate("/d/#{proposal.discussionKey}")
  return
