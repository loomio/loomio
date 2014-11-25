angular.module('loomioApp').factory 'MembershipService', ($http, RestfulService) ->
  new class MembershipService extends RestfulService
    resource_plural: 'memberships'

    fetchMyMemberships: (success, failure) ->
      @fetch({}, success, failure, 'my_memberships')

    fetchByNameFragment: (fragment, groupId, success, failure) ->
      @fetch({q: fragment, group_id: groupId}, success, failure, 'autocomplete')

    fetchByGroup: (groupId, success, failure) ->
      @fetch({group_id: groupId}, success, failure)
