import BaseRecordsInterface  from '@/shared/record_store/base_records_interface'
import OauthApplicationModel from '@/shared/models/oauth_application_model'

export default class OauthApplicationRecordsInterface extends BaseRecordsInterface
  model: OauthApplicationModel

  fetchOwned: (options = {}) ->
    @fetch
      path: 'owned'
      params: options

  fetchAuthorized: (options = {}) ->
    @fetch
      path: 'authorized'
      params: options
