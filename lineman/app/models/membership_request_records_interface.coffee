angular.module('loomioApp').factory 'MembershipRequestRecordsInterface', (BaseRecordsInterface, MembershipRequestModel) ->
  class MembershipRequestRecordsInterface extends BaseRecordsInterface
    model: MembershipRequestModel

    fetchPendingByGroup: (groupKey, options = {}) ->
      @restfulClient.get('/pending', group_key: groupKey)
