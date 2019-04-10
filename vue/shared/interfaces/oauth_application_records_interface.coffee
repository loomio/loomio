BaseRecordsInterface  = require 'shared/record_store/base_records_interface'
OauthApplicationModel = require 'shared/models/oauth_application_model'

module.exports = class OauthApplicationRecordsInterface extends BaseRecordsInterface
  model: OauthApplicationModel

  fetchOwned: (options = {}) ->
    @fetch
      path: 'owned'
      params: options

  fetchAuthorized: (options = {}) ->
    @fetch
      path: 'authorized'
      params: options
