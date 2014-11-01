angular.module('loomioApp').factory 'ProposalService', ($http, RestfulService) ->
  new class ProposalService extends RestfulService
    resource_plural: 'proposals'

    fetchByDiscussion: (discussion_id, success, failure) ->
      @fetch({discussion_id: discussion_id}, success, failure)
