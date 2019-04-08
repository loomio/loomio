import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import StanceModel          from '@/shared/models/stance_model'

export default class StanceRecordsInterface extends BaseRecordsInterface
  model: StanceModel

  fetchMyStances: (groupKey, options = {}) ->
    options['group_id'] = groupKey
    @fetch
      path: 'my_stances'
      params: options

  fetchMyStancesByDiscussion: (discussionKey, options = {}) ->
    options['discussion_id'] = discussionKey
    @fetch
      path: 'my_stances'
      params: options
