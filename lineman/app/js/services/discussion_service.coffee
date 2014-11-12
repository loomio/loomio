angular.module('loomioApp').factory 'DiscussionService', ($http, RestfulService) ->
  new class DiscussionService extends RestfulService
    resource_plural: 'discussions'

    fetchByGroup: (group, page, success, failure) ->
      @fetch({group_id: group.id, page: page}, success, failure)
