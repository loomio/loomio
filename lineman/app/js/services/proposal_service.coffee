angular.module('loomioApp').factory 'ProposalService', ($http) ->
  new class ProposalService
    constructor: ->

    create: (proposal, success, failure) ->
      $http.post('/api/v1/motions', proposal.params()).then (response) ->
        success()
      , (response) ->
        failure(response.data.error)
