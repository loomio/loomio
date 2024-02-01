import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import SessionModel         from '@/shared/models/session_model';

export default class SessionRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = SessionModel;
    this.baseConstructor(recordStore);
  }
}
