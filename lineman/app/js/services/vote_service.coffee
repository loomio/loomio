angular.module('loomioApp').factory 'VoteService', ($http, RestfulService) ->
  new class VoteService extends RestfulService
    resource_plural: 'votes'

    fetchByCurrentUserAndDiscussion: (user_id, discussion_id, success, failure) ->
      @fetch({user_id: user_id, discussion_id: discussion_id}, success, failure)

    fetchByProposal: (proposal_id, success, failure) ->
      @fetch({proposal_ids: [proposal_id]}, success, failure)