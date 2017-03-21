angular.module('loomioApp').factory 'CommunityRecordsInterface', (BaseRecordsInterface, CommunityModel) ->
  class CommunityRecordsInterface extends BaseRecordsInterface
    model: CommunityModel
