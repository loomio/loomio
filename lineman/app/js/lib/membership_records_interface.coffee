angular.module('loomioApp').factory 'MembershipRecordsInterface', (BaseRecordsInterface, MembershipModel) ->
  class MembershipRecordsInterface extends BaseRecordsInterface
    model: MembershipModel

    fetchMyMemberships: (success, failure) ->
      @restfulClient.get 'my_memberships', {},
        (data) ->
          @recordStore.import(data)
          success()
      , failure

    fetchByNameFragment: (fragment, groupKey, success, failure) ->
      @restfulClient.get 'autocomplete', {q: fragment, group_key: groupKey}, @importAndInvoke(success), failure

    fetchByGroupKey: (groupKey, success, failure) ->
      @restfulClient.getCollection {group_key: groupKey}, @importAndInvoke(success), failure

    makeAdmin: (membership, success, failure) ->
      @restfulClient.post "#{membership.id}/make_admin", {}, @importAndInvoke(success), failure

    removeAdmin: (membership, success, failure) ->
      @restfulClient.post "#{membership.id}/remove_admin", {}, @importAndInvoke(success), failure

