import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import DiscussionModel      from '@/shared/models/discussion_model'
import Session              from '@/shared/services/session'
import EventBus             from '@/shared/services/event_bus'
import NullDiscussionModel  from '@/shared/models/null_discussion_model'
import { includes } from 'lodash'

export default class DiscussionRecordsInterface extends BaseRecordsInterface
  model: DiscussionModel

  nullModel: -> new NullDiscussionModel()

  search: (groupKey, fragment, options = {}) ->
    options.group_id = groupKey
    options.q = fragment
    @fetch
      path: 'search'
      params: options

  fetchByGroup: (groupKey, options = {}) ->
    options['group_id'] = groupKey
    @fetch
      params: options

  fetchInbox: (options = {}) ->
    @fetch
      path: 'dashboard'
      params:
        exclude_types: 'group'
        per: 50
