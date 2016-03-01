angular.module('loomioApp').factory 'OauthApplicationRecordsInterface', (BaseRecordsInterface, OauthApplicationModel) ->
  class OauthApplicationRecordsInterface extends BaseRecordsInterface
    model: OauthApplicationModel

    fetchOwned: (options = {}) ->
      @fetch
        path: 'owned'
        params: options

    fetchAuthorized: (options = {}) ->
      @fetch
        path: 'authorized'
        params: options
