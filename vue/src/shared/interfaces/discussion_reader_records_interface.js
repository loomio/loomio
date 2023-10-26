/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let DiscussionReaderRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import DiscussionReaderModel from '@/shared/models/discussion_reader_model';
import Session              from '@/shared/services/session';
import EventBus             from '@/shared/services/event_bus';
import { includes } from 'lodash';

export default DiscussionReaderRecordsInterface = (function() {
  DiscussionReaderRecordsInterface = class DiscussionReaderRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = DiscussionReaderModel;
    }
  };
  DiscussionReaderRecordsInterface.initClass();
  return DiscussionReaderRecordsInterface;
})();
