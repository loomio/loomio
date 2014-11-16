angular.module('loomioApp').factory 'InvitableService', ($http, RestfulService) ->
  new class InvitableService extends RestfulService
    resource_plural: 'invitables'

    fetchByNameFragment: (fragment, groupId, success, failure) ->
      @fetch({q: fragment, group_id: groupId}, success, failure)
