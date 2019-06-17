import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import TagModel  from '@/shared/models/tag_model'

export default class TagRecordsInterface extends BaseRecordsInterface
  model: TagModel

  fetchByGroup: (group) ->
    @fetch
      params:
        group_id: group.id
