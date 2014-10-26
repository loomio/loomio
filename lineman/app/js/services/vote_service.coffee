angular.module('loomioApp').factory 'VoteService', ($http) ->
  new class VoteService
    constructor: ->

    create: (vote, success, failure) ->
      $http.post('/api/v1/votes', {vote: vote.params()}).then (response) ->
        success()
      , (response) ->
        failure(response.data.error)
