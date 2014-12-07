angular.module('loomioApp').factory 'MembershipRecordsInterface', (BaseRecordsInterface, MembershipModel) ->
  class MembershipRecordsInterface extends BaseRecordsInterface
    model: MembershipModel

    fetchMyMemberships: (success, failure) ->
      @restfulClient.get 'my_memberships'

    fetchByNameFragment: (fragment, groupKey, success, failure) ->
      @restfulClient.get 'autocomplete', {q: fragment, group_key: groupKey}

    fetchByGroup: (group, success, failure) ->
      @restfulClient.getCollection {group_id: group.id}

    makeAdmin: (membership, success, failure) ->
      @restfulClient.postMember membership.id "make_admin"

    removeAdmin: (membership, success, failure) ->
      @restfulClient.postMember membership.id "remove_admin"

