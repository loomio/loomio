import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import DiscussionReaderModel from '@/shared/models/discussion_reader_model'
import Session              from '@/shared/services/session'
import EventBus             from '@/shared/services/event_bus'
import { includes } from 'lodash'

export default class DiscussionReaderRecordsInterface extends BaseRecordsInterface
  model: DiscussionReaderModel

  # fetchInbox: (options = {}) ->
  #   @fetch
  #     path: 'inbox'
  #     params:
  #       from: options['from'] or 0
  #       per: options['per'] or 100
