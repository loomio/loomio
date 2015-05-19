angular.module('loomioApp').factory 'MembershipRecordsInterface', (BaseRecordsInterface, MembershipModel) ->
  class MembershipRecordsInterface extends BaseRecordsInterface
    model: MembershipModel

    fetchMyMemberships: ->
      @fetch
        path: 'my_memberships'
        cacheKey: 'myMemberships'

    fetchByNameFragment: (fragment, groupKey) ->
      @fetch
        path: 'autocomplete'
        params: { q: fragment, group_key: groupKey }

    fetchByGroup: (groupKey, options = {}) ->
      @fetch
        params: { group_key: groupKey },
        cacheKey: "membershipsFor#{groupKey}"

    makeAdmin: (membership) ->
      @restfulClient.postMember membership.id "make_admin"

    removeAdmin: (membership) ->
      @restfulClient.postMember membership.id "remove_admin"
