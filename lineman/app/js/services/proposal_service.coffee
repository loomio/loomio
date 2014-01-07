angular.module('loomioApp').service 'ProposalService',
  class ProposalService
    constructor: (@$http) ->

    create: (proposal, onSuccess, onFailure) ->
      @$http.post('/api/motions', proposal).then (response) ->
        onSuccess(response.data.event)
      , (response) ->
        onFailure(response.data.errors)

    saveVote: (vote, onSuccess, onFailure) ->
      @$http.post("/api/motions/#{vote.proposal_id}/vote", vote).then (response) ->
        onSuccess(response.data.event)
      , (response) ->
        onFailure(response.data.errors)
