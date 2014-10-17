angular.module('loomioApp').service 'ProposalService',
  class ProposalService
    constructor: (@$http, @EventService) ->

    create: (proposal, success, failure) ->
      @$http.post('/api/motions', proposal).then (response) ->
        success()
      , (response) ->
        failure(response.data.error)

    saveVote: (vote, success, failure) ->
      console.log(vote)
      vote.motion_id = vote.proposal_id
      @$http.post("/api/motions/#{vote.proposal_id}/vote", vote).then (response) ->
        success(response.data.event)
      , (response) ->
        failure(response.data.error)



