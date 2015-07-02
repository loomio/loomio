angular.module('loomioApp').factory 'MembershipRequestRecordsInterface', (BaseRecordsInterface, MembershipRequestModel) ->
  class MembershipRequestRecordsInterface extends BaseRecordsInterface
    model: MembershipRequestModel

    fetchPendingByGroup: (groupKey, options = {}) ->
      @restfulClient.get('/pending', group_key: groupKey)

    fetchRespondedToByGroup: (groupKey, options = {}) ->
      @restfulClient.get('/responded_to', group_key: groupKey)

    approve: (membershipRequest) ->
      @restfulClient.postMember(membershipRequest.id, 'approve', group_key: membershipRequest.group().key)
