angular.module('loomioApp').factory 'VoteService', ($http, RestfulService, RecordStoreService) ->
  new class VoteService extends RestfulService
    resource_plural: 'votes'

    fetchMyVotes: (discussion) ->
      $http.get("/api/v1/votes/my_votes", params: { discussion_id: discussion.id }).then (response) ->
        RecordStoreService.importRecords(response.data)

    fetchByProposal: (proposal, success, failure) ->
      @fetch({motion_id: proposal.id}, success, failure)