angular.module('loomioApp').factory 'MembershipRequestRecordsInterface', (BaseRecordsInterface, MembershipRequestModel) ->
  class MembershipRequestRecordsInterface extends BaseRecordsInterface
    model: MembershipRequestModel

    fetchMyPendingByGroup: (groupKey, options = {}) ->
      options['group_key'] = groupKey
      @restfulClient.get('/my_pending', options)

    fetchPendingByGroup: (groupKey, options = {}) ->
      options['group_key'] = groupKey
      @restfulClient.get('/pending', options)

    fetchPreviousByGroup: (groupKey, options = {}) ->
      options['group_key'] = groupKey
      @restfulClient.get('/previous', options)

    approve: (membershipRequest) ->
      @restfulClient.postMember(membershipRequest.id, 'approve', group_key: membershipRequest.group().key)

    ignore: (membershipRequest) ->
      @restfulClient.postMember(membershipRequest.id, 'ignore', group_key: membershipRequest.group().key)
