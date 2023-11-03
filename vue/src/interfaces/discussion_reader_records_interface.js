import BaseRecordsInterface from '@/record_store/base_records_interface';
import DiscussionReaderModel from '@/models/discussion_reader_model';
import Session              from '@/services/session';
import EventBus             from '@/services/event_bus';
import { includes } from 'lodash';

export default class DiscussionReaderRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = DiscussionReaderModel;
    this.baseConstructor(recordStore);
  }
}
