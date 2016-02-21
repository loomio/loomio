angular.module('loomioApp').factory 'OauthApplicationRecordsInterface', (BaseRecordsInterface, OauthApplicationModel) ->
  class OauthApplicationRecordsInterface extends BaseRecordsInterface
    model: OauthApplicationModel
