angular.module('loomioApp').factory 'MembershipRequestRecordsInterface', (BaseRecordsInterface, MembershipRequestModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    model: MembershipRequestModel
