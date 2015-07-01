angular.module('loomioApp').factory 'MembershipRecordsInterface', (BaseRecordsInterface, MembershipModel) ->
  class MembershipRecordsInterface extends BaseRecordsInterface
    model: MembershipModel

    fetchMyMemberships: ->
      @fetch
        path: 'my_memberships'

    # There's a pattern emerging for searching by fragment...
    fetchByNameFragment: (fragment, groupKey, limit = 5) ->
      @fetch
        path: 'autocomplete'
        params: { q: fragment, group_key: groupKey, per: limit }

    fetchInvitables: (fragment, groupKey, limit = 5) ->
      @fetch
        path: 'invitables'
        params: { q: fragment, group_key: groupKey, per: limit }

    fetchByGroup: (groupKey, options = {}) ->
      @fetch
        params:
          group_key: groupKey
          per: options['per']

    makeAdmin: (membership) ->
      @restfulClient.postMember membership.id, "make_admin"

    removeAdmin: (membership) ->
      @restfulClient.postMember membership.id, "remove_admin"
