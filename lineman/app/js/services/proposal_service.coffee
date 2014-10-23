angular.module('loomioApp').service 'ProposalService',
  class ProposalService
    constructor: (@$http) ->

    create: (proposal, success, failure) ->
      @$http.post('/api/v1/motions', proposal.params()).then (response) ->
        success()
      , (response) ->
        failure(response.data.error)

    #saveVote: (vote, success, failure) ->
      #console.log(vote)
      #vote.motion_id = vote.proposal_id
      #@$http.post("/api/v1/motions/#{vote.proposalId}/vote", vote).then (response) ->
        #success(response.data.event)
      #, (response) ->
        #failure(response.data.error)



