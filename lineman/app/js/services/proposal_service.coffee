angular.module('loomioApp').service 'ProposalService',
  class ProposalService
    constructor: (@$http, @EventService) ->

    create: (proposal, success, failure) ->
      @$http.post('/api/v1/motions', proposal).then (response) ->
        success(response.data.proposals[0])
      , (response) ->
        failure(response.data.error)

    saveVote: (vote, success, failure) ->
      @$http.post("/api/v1/motions/#{vote.proposalId}/vote", vote).then (response) ->
        success()
      , (response) ->
        failure(response.data.error)



