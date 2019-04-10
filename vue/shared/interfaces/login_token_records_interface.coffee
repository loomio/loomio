BaseRecordsInterface = require 'shared/record_store/base_records_interface'

module.exports = class LoginTokenRecordsInterface extends BaseRecordsInterface
  model:
    singular: 'login_token'
    plural:   'login_tokens'

  fetchToken: (email) ->
    @remote.post('', email: email)
