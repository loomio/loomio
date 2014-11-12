angular.module('loomioApp').factory 'VoteService', ($http, RestfulService, RecordStoreService) ->
  new class VoteService extends RestfulService
    resource_plural: 'votes'

    fetchMyVotes: (discussion, success, failure) ->
      @fetch({ discussion_id: discussion.id }, success, failure, 'my_votes')

    fetchByProposal: (proposal, success, failure) ->
      @fetch({motion_id: proposal.id}, success, failure)