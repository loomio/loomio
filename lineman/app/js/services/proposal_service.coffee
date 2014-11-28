angular.module('loomioApp').factory 'ProposalService', ($http, RestfulService) ->
  new class ProposalService extends RestfulService
    resource_plural: 'proposals'

    fetchByDiscussion: (discussion, success, failure) ->
      @fetch({discussion_id: discussion.id}, success, failure)

    close: (proposal, success, failure) ->
      $http.post("#{@showPath(proposal.id)}/close").then (response) ->
        success() if success?
      , (response) ->
        failure() if failure?