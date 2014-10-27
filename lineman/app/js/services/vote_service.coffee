angular.module('loomioApp').factory 'VoteService', ($http, RestfulService) ->
  new class VoteService extends RestfulService
    resource_plural: 'votes'
