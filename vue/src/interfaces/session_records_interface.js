import BaseRecordsInterface from '@/record_store/base_records_interface';
import SessionModel         from '@/models/session_model';

export default class SessionRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = SessionModel;
    this.baseConstructor(recordStore);
  }
}
