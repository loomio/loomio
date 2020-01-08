import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import SamlProviderModel           from '@/shared/models/saml_provider_model'
# import {uniq, concat, compact, map, includes} from 'lodash'
export default class GroupRecordsInterface extends BaseRecordsInterface
  model: SamlProviderModel
  
  fetchByGroupId: (id) ->
    @fetch
      params:
        group_id: id

  fetchByDiscussionId: (id) ->
    @fetch
      params:
        discussion_id: id
