import BaseRecordsInterface from '@/shared/record_store/base_records_interface'

export default class LoginTokenRecordsInterface extends BaseRecordsInterface
  model:
    singular: 'login_token'
    plural:   'login_tokens'

  fetchToken: (email) ->
    @remote.post('', email: email)
