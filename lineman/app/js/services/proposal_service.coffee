angular.module('loomioApp').service 'ProposalService',
  class ProposalService
    constructor: (@$http, @RecordCacheService) ->

    create: (proposal, onSuccess, onFailure) ->
      @$http.post('/api/motions', proposal).then (response) =>
        event = response.data.event
        @RecordCacheService.consumeSideLoadedRecords(response.data)
        @RecordCacheService.hydrateRelationshipsOn(event)
        onSuccess(event)
      , (response) ->
        onFailure(response.data.error)

    saveVote: (vote, onSuccess, onFailure) ->
      @$http.post("/api/motions/#{vote.proposal_id}/vote", vote).then (response) ->
        onSuccess(response.data.event)
      , (response) ->
        onFailure(response.data.error)
