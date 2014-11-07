angular.module('loomioApp').factory 'ProposalService', ($http, RestfulService) ->
  new class ProposalService extends RestfulService
    resource_plural: 'proposals'

    fetchByDiscussion: (discussion, success, failure) ->
      @fetch({discussion_id: discussion.id}, success, failure)
