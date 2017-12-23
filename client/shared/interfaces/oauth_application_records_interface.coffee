BaseRecordsInterface  = require 'shared/interfaces/base_records_interface.coffee'
OauthApplicationModel = require 'shared/models/oauth_application_model.coffee'

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
