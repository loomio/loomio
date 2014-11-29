angular.module('loomioApp').factory 'MembershipRecordsInterface', (BaseRecordsInterface, MembershipModel) ->
  class MembershipRecordsInterface extends BaseRecordsInterface
    @model: MembershipModel

    fetchMyMemberships: (success, failure) ->
      @restfulClient.fetch({}, success, failure, 'my_memberships')

    fetchByNameFragment: (fragment, groupId, success, failure) ->
      @restfulClient.fetch({q: fragment, group_id: groupId}, success, failure, 'autocomplete')

    fetchByGroup: (groupId, success, failure) ->
      @restfulClient.fetch({group_id: groupId}, success, failure)

    makeAdmin: (membership, success, failure) ->
      @save(membership, success, failure, 'make_admin')

    removeAdmin: (membership, success, failure) ->
      @save(membership, success, failure, 'remove_admin')
