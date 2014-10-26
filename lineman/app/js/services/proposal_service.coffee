angular.module('loomioApp').factory 'ProposalService', ($http, RestfulService) ->
  new class ProposalService extends RestfulService
    resource_plural: 'motions'
