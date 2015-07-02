angular.module('loomioApp').factory 'MembershipRequestRecordsInterface', (BaseRecordsInterface, MembershipRequestModel) ->
  class MembershipRequestRecordsInterface extends BaseRecordsInterface
    model: MembershipRequestModel

    fetchPendingByGroup: (groupKey, options = {}) ->
      @restfulClient.get('/pending', group_key: groupKey)

    fetchPreviousByGroup: (groupKey, options = {}) ->
      @restfulClient.get('/previous', group_key: groupKey)

    approve: (membershipRequest) ->
      @restfulClient.postMember(membershipRequest.id, 'approve', group_key: membershipRequest.group().key)

    ignore: (membershipRequest) ->
      @restfulClient.postMember(membershipRequest.id, 'ignore', group_key: membershipRequest.group().key)
