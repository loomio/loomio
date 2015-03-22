angular.module('loomioApp').factory 'MembershipRecordsInterface', (BaseRecordsInterface, MembershipModel) ->
  class MembershipRecordsInterface extends BaseRecordsInterface
    model: MembershipModel

    fetchMyMemberships: ->
      @restfulClient.get 'my_memberships'

    fetchByNameFragment: (fragment, groupKey) ->
      @restfulClient.get 'autocomplete', {q: fragment, group_key: groupKey}

    fetchByGroup: (groupKey) ->
      @restfulClient.getCollection {group_key: groupKey}

    makeAdmin: (membership) ->
      @restfulClient.postMember membership.id "make_admin"

    removeAdmin: (membership) ->
      @restfulClient.postMember membership.id "remove_admin"

