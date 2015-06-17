angular.module('loomioApp').factory 'MembershipRecordsInterface', (BaseRecordsInterface, MembershipModel) ->
  class MembershipRecordsInterface extends BaseRecordsInterface
    model: MembershipModel

    fetchMyMemberships: ->
      @fetch
        path: 'my_memberships'
        cacheKey: 'myMemberships'

    # There's a pattern emerging for searching by fragment...
    fetchByNameFragment: (fragment, groupKey, limit = 5) ->
      @fetch
        path: 'autocomplete'
        params: { q: fragment, group_key: groupKey, per: limit }
    
    fetchInvitables: (fragment, groupKey, limit = 5) ->
      @fetch
        path: 'invitables'
        params: { q: fragment, group_key: groupKey, per: limit }

    fetchByGroup: (group, options = {}) ->
      @fetch
        params: { group_key: group.key },
        cacheKey: "membershipsFor#{group.key}"

    makeAdmin: (membership) ->
      @restfulClient.postMember membership.id "make_admin"

    removeAdmin: (membership) ->
      @restfulClient.postMember membership.id "remove_admin"
