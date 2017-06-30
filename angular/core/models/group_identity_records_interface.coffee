angular.module('loomioApp').factory 'GroupIdentityRecordsInterface', (BaseRecordsInterface, GroupIdentityModel) ->
  class GroupIdentityRecordsInterface extends BaseRecordsInterface
    model: GroupIdentityModel
