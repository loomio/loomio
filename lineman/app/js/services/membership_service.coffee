angular.module('loomioApp').factory 'MembershipService', ($http, RestfulService) ->
  new class MembershipService extends RestfulService
    resource_plural: 'memberships'

    fetchByNameFragment: (fragment, groupId, success, failure) ->
      @fetch({q: fragment, group_id: groupId}, success, failure, 'autocomplete')
