angular.module('loomioApp').service 'ProposalService',
  class ProposalService
    constructor: (@$http, @EventService) ->

    create: (proposal, onSuccess, onFailure) ->
      @$http.post('/api/motions', proposal).then (response) =>
        @EventService.consumeEventFromResponseData(response.data)
        onSuccess(response.data.event)
      , (response) ->
        onFailure(response.data.error)

    saveVote: (vote, onSuccess, onFailure) ->
      console.log(vote)
      vote.motion_id = vote.proposal_id
      @$http.post("/api/motions/#{vote.proposal_id}/vote", vote).then (response) =>
        @EventService.consumeEventFromResponseData(response.data)
        onSuccess(response.data.event)
      , (response) ->
        onFailure(response.data.error)



